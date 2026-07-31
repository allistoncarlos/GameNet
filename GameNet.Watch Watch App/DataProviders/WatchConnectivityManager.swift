//
//  WatchConnectivityManager.swift
//  GameNet.Watch Watch App
//
//  Created by Alliston Aleixo on 23/05/26.
//

import Foundation
import WatchConnectivity
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Persistência local

private enum WatchCoverImageCache {
    private static var directory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent("WatchCovers", isDirectory: true)
    }

    private static func fileURL(for gameId: String) -> URL {
        let safeName = gameId
            .addingPercentEncoding(withAllowedCharacters: .alphanumerics)
            ?? String(gameId.hashValue)
        return directory.appendingPathComponent("\(safeName).jpg")
    }

    static func save(gameId: String, data: Data) {
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try? data.write(to: fileURL(for: gameId), options: .atomic)
    }

    static func load(gameId: String) -> Data? {
        try? Data(contentsOf: fileURL(for: gameId))
    }
}

private enum WatchPlayingGamesCache {
    private static let fileName = "watch-playing-games.json"

    private static var fileURL: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return directory.appendingPathComponent(fileName)
    }

    static func load() -> WatchPlayingGamesPayload? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(WatchPlayingGamesPayload.self, from: data)
    }

    static func save(_ payload: WatchPlayingGamesPayload) {
        let directory = fileURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        guard let data = try? JSONEncoder().encode(payload) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}

// MARK: - WatchConnectivityManager

@MainActor
final class WatchConnectivityManager: NSObject, ObservableObject {
    override private init() {
        super.init()
    }

    static let shared = WatchConnectivityManager()

    @Published var context: [String: Any] = [:]
    @Published var state: WCSessionActivationState = .notActivated
    @Published private(set) var isReachable = false
    @Published private(set) var cachedPayload: WatchPlayingGamesPayload?
    @Published private(set) var cachedAuthStatus: WatchAuthStatus?
    @Published private(set) var coverRevision = 0

    private var activationContinuations: [CheckedContinuation<Void, Never>] = []

    func activateSession() {
        guard WCSession.isSupported() else { return }

        if WCSession.default.activationState == .activated {
            state = .activated
            isReachable = WCSession.default.isReachable
            refreshCachedPayload()
            return
        }

        WCSession.default.delegate = self
        WCSession.default.activate()
        refreshCachedPayload()
    }

    func waitForActivation(timeoutSeconds: Double = 2) async {
        if WCSession.default.activationState == .activated {
            state = .activated
            return
        }

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            activationContinuations.append(continuation)

            Task { @MainActor in
                let steps = Int(timeoutSeconds * 10)
                for _ in 0..<steps {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    if WCSession.default.activationState == .activated {
                        finishActivation()
                        return
                    }
                }
                finishActivation()
            }
        }
    }

    func sendMessage(
        message: Any = true,
        key: String,
        replyHandler: (([String: Any]) -> Void)?,
        errorHandler: ((Error) -> Void)? = nil
    ) {
        guard WCSession.default.activationState == .activated else {
            errorHandler?(WCError(.sessionNotActivated))
            return
        }

        guard WCSession.default.isCompanionAppInstalled else {
            errorHandler?(WCError(.companionAppNotInstalled))
            return
        }

        guard WCSession.default.isReachable else {
            errorHandler?(WCError(.notReachable))
            return
        }

        WCSession.default.sendMessage(
            [key: message],
            replyHandler: replyHandler,
            errorHandler: { error in
                errorHandler?(error)
            }
        )
    }

    func sendMessageWithTimeout(
        message: Any = true,
        key: String,
        timeout: TimeInterval = 8,
        replyHandler: @escaping ([String: Any]) -> Void,
        errorHandler: @escaping (Error) -> Void
    ) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            var didFinish = false

            func finish(_ block: () -> Void) {
                guard !didFinish else { return }
                didFinish = true
                block()
                continuation.resume()
            }

            sendMessage(
                message: message,
                key: key,
                replyHandler: { reply in
                    finish { replyHandler(reply) }
                },
                errorHandler: { error in
                    finish { errorHandler(error) }
                }
            )

            Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                finish { errorHandler(WCError(.notReachable)) }
            }
        }
    }

    func coverImageData(for gameId: String) -> Data? {
        WatchCoverImageCache.load(gameId: gameId)
    }

    func persistPayload(_ payload: WatchPlayingGamesPayload) {
        cachedPayload = payload
        WatchPlayingGamesCache.save(payload)
    }

    /// Ingere capas presentes em qualquer dicionário recebido do iPhone
    /// (applicationContext, reply de `sendMessage`, etc.). Pode ser chamado várias
    /// vezes — sobrescreve o cache local com a versão mais recente.
    func ingestCovers(from container: [String: Any]) {
        guard let covers = container[WatchMessageKey.playingGameCovers] as? [String: Data],
              !covers.isEmpty else {
            return
        }

        var didSaveAny = false
        for (gameId, data) in covers {
            #if canImport(UIKit)
            guard UIImage(data: data) != nil else { continue }
            #endif
            WatchCoverImageCache.save(gameId: gameId, data: data)
            didSaveAny = true
        }

        if didSaveAny {
            coverRevision &+= 1
        }
    }

    func refreshCachedPayload() {
        let applicationContext = WCSession.default.receivedApplicationContext
        let mergedContext = applicationContext.isEmpty ? context : applicationContext

        if let statusRaw = mergedContext[WatchMessageKey.authStatus] as? String,
           let status = WatchAuthStatus(rawValue: statusRaw) {
            cachedAuthStatus = status
        }

        if let data = mergedContext[WatchMessageKey.playingGames] as? Data,
           let payload = WatchConnectivityPayloadCodec.decode(WatchPlayingGamesPayload.self, from: data) {
            cachedPayload = payload
            WatchPlayingGamesCache.save(payload)
        } else if let diskPayload = WatchPlayingGamesCache.load() {
            cachedPayload = diskPayload
        }

        ingestCovers(from: mergedContext)
    }

    func playingGamesFromContext() -> WatchPlayingGamesPayload? {
        refreshCachedPayload()
        return cachedPayload
    }

    // MARK: Private

    private func finishActivation() {
        state = WCSession.default.activationState
        isReachable = WCSession.default.isReachable

        let pending = activationContinuations
        activationContinuations.removeAll()
        pending.forEach { $0.resume() }

        refreshCachedPayload()
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task { @MainActor in
            state = activationState
            isReachable = session.isReachable
            finishActivation()
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            isReachable = session.isReachable
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        Task { @MainActor in
            context = applicationContext
            refreshCachedPayload()
        }
    }
}
