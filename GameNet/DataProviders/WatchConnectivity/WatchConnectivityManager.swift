//
//  WatchConnectivityManager.swift
//  GameNet
//
//  Created by Alliston Aleixo on 07/01/23.
//

#if canImport(WatchConnectivity)
import Foundation
import WatchConnectivity

// MARK: - WatchConnectivityManager

final class WatchConnectivityManager: NSObject, ObservableObject {

    // MARK: Lifecycle

    override private init() {
        super.init()
    }

    // MARK: Internal

    static let shared = WatchConnectivityManager()

    @Published var context: [String: Any] = [:]
    @Published var message: [String: Any] = [:]
    @Published var state: WCSessionActivationState = .notActivated

    func activateSession() {
        if WCSession.isSupported() {
            WCSession.default.delegate = WatchConnectivityManager.shared
            WCSession.default.activate()
        }
    }

    func sendMessage(
        message: Any,
        key: String
    ) {
        sendMessage(message: message, key: key, replyHandler: nil)
    }

    func sendMessage(
        message: Any = true,
        key: String,
        replyHandler: (([String: Any]) -> Void)?,
        errorHandler: ((Error) -> Void)? = nil
    ) {
        do {
            try validateSessionForMessaging()

            WCSession.default.sendMessage(
                [key: message],
                replyHandler: replyHandler,
                errorHandler: { error in
                    print("Cannot send message: \(String(describing: error))")
                    errorHandler?(error)
                }
            )
        } catch {
            print("[WATCH SESSION] - Error: \(error.localizedDescription)")
            errorHandler?(error)
        }
    }

    func updateApplicationContext(message: Any, key: String) {
        do {
            try validateSessionForContext()
            try WCSession.default.updateApplicationContext([key: message])
        } catch {
            print("[WATCH SESSION] - Error: \(error.localizedDescription)")
        }
    }

    func playingGamesFromContext() -> WatchPlayingGamesPayload? {
        guard let data = WCSession.default.receivedApplicationContext[WatchMessageKey.playingGames] as? Data else {
            return nil
        }
        return WatchConnectivityPayloadCodec.decode(WatchPlayingGamesPayload.self, from: data)
    }

    // MARK: Private

    private func validateSessionForMessaging() throws {
        guard WCSession.default.activationState == .activated else {
            throw WCError(.sessionNotActivated)
        }

        #if os(iOS)
            guard WCSession.default.isWatchAppInstalled else {
                throw WCError(.watchAppNotInstalled)
            }
        #else
            guard WCSession.default.isCompanionAppInstalled else {
                throw WCError(.companionAppNotInstalled)
            }
        #endif

        guard WCSession.default.isReachable else {
            throw WCError(.notReachable)
        }
    }

    private func validateSessionForContext() throws {
        guard WCSession.default.activationState == .activated else {
            throw WCError(.sessionNotActivated)
        }
    }
}

// MARK: WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        self.message = message
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        self.message = message

        #if os(iOS)
            Task { @MainActor in
                let reply = await WatchPhoneCoordinator.shared.handle(message: message)
                replyHandler(reply)
            }
        #else
            replyHandler([:])
        #endif
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        state = activationState
        print("[WATCH SESSION] - State: \(activationState)")
    }

    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        context = applicationContext
    }

    #if os(iOS)
        func sessionDidBecomeInactive(_ session: WCSession) {}
        func sessionDidDeactivate(_ session: WCSession) {
            session.activate()
        }
    #endif
}
#endif
