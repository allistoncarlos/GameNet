import Foundation
import Network

enum APIConfig {
    static var localURL: URL? { url(forKey: "API_PATH_LOCAL") }

    static var remoteURL: URL? { url(forKey: "API_PATH_REMOTE") ?? url(forKey: "API_PATH") }

    static var fallbackURL: URL {
        guard let url = remoteURL ?? localURL else {
            fatalError("API_PATH_LOCAL / API_PATH_REMOTE não configurados em Resources/Config.xcconfig")
        }
        return url
    }

    private static func url(forKey key: String) -> URL? {
        guard let raw = Bundle.main.infoDictionary?[key] as? String,
              !raw.isEmpty, !raw.contains("$("),
              let url = URL(string: raw), url.host != nil else { return nil }
        return url
    }
}

final class APIRoute: @unchecked Sendable {
    static let shared = APIRoute()

    private enum Step {
        case ready(URL)
        case wait(Task<URL, Never>, Int)
    }

    private let lock = NSLock()
    private var current: URL?
    private var probeTask: Task<URL, Never>?
    private var generation = 0
    private var localAllowed = true
    private var sawFirstPath = false
    private var pathSignature = ""
    private let monitor = NWPathMonitor()

    private static let probeSession: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 2.5
        config.timeoutIntervalForResource = 3
        config.waitsForConnectivity = false
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: config)
    }()

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            let interfaces = path.availableInterfaces
                .map { "\($0.name):\($0.type)" }
                .joined(separator: ",")
            let gateways = path.gateways.map { "\($0)" }.joined(separator: ",")
            let signature = "\(path.status)|\(interfaces)|\(gateways)"
            let changed: Bool = self.lock.withLock {
                self.sawFirstPath = true
                guard self.pathSignature != signature else { return false }
                self.pathSignature = signature
                return true
            }
            if changed { self.invalidate() }
        }
        monitor.start(queue: DispatchQueue(label: "gamenet.api.route", qos: .utility))
    }

    func start() {}

    var canUseLocal: Bool {
        guard APIConfig.localURL != nil else { return false }
        let path = monitor.currentPath
        return path.usesInterfaceType(.wifi) || path.usesInterfaceType(.wiredEthernet)
    }

    func invalidate() {
        lock.withLock {
            current = nil
            probeTask = nil
            generation += 1
        }
    }

    func resolve() async -> URL {
        await waitForFirstPath()
        let step: Step = lock.withLock {
            if let current { return .ready(current) }
            if let probeTask { return .wait(probeTask, generation) }
            let allowLocal = localAllowed && canUseLocal
            let task = Task { await Self.probe(allowLocal: allowLocal) }
            probeTask = task
            return .wait(task, generation)
        }
        switch step {
        case .ready(let url):
            return url
        case .wait(let task, let gen):
            let url = await task.value
            lock.withLock {
                if generation == gen {
                    current = url
                    probeTask = nil
                }
            }
            return url
        }
    }

    private func waitForFirstPath() async {
        for _ in 0..<20 {
            if lock.withLock({ sawFirstPath }) { return }
            try? await Task.sleep(nanoseconds: 50_000_000)
        }
    }

    private static func probe(allowLocal: Bool) async -> URL {
        let remote = APIConfig.remoteURL
        guard allowLocal, let local = APIConfig.localURL else {
            return remote ?? APIConfig.fallbackURL
        }
        guard let remote, remote != local else { return local }
        return await isReachable(local) ? local : remote
    }

    private static func isReachable(_ base: URL) async -> Bool {
        var request = URLRequest(url: base)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 2.5
        do {
            _ = try await probeSession.data(for: request)
            return true
        } catch {
            return false
        }
    }
}

enum APIConnectivity {
    static func isConnectivityError(_ error: Error) -> Bool {
        if error is CancellationError { return false }
        let nsError = error as NSError
        if nsError.domain == NSPOSIXErrorDomain { return true }
        if let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? Error,
           isConnectivityError(underlying) {
            return true
        }
        guard nsError.domain == NSURLErrorDomain else { return false }
        let codes: Set<Int> = [
            NSURLErrorNotConnectedToInternet,
            NSURLErrorNetworkConnectionLost,
            NSURLErrorTimedOut,
            NSURLErrorCannotConnectToHost,
            NSURLErrorCannotFindHost,
            NSURLErrorDNSLookupFailed,
            NSURLErrorInternationalRoamingOff,
            NSURLErrorDataNotAllowed,
            NSURLErrorSecureConnectionFailed,
        ]
        return codes.contains(nsError.code)
    }
}
