//
//  WatchConnectivityManager.swift
//  GameNet.Watch Watch App
//
//  Created by Alliston Aleixo on 23/05/26.
//

import Foundation
import WatchConnectivity

final class WatchConnectivityManager: NSObject, ObservableObject {
    override private init() {
        super.init()
    }

    static let shared = WatchConnectivityManager()

    @Published var context: [String: Any] = [:]
    @Published var state: WCSessionActivationState = .notActivated

    func activateSession() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
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

    func playingGamesFromContext() -> WatchPlayingGamesPayload? {
        let context = WCSession.default.receivedApplicationContext
        guard let data = context[WatchMessageKey.playingGames] as? Data else {
            return nil
        }
        return WatchConnectivityPayloadCodec.decode(WatchPlayingGamesPayload.self, from: data)
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        state = activationState
    }

    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        context = applicationContext
    }
}
