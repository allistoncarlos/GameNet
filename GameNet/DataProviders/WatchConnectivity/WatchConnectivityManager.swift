//
//  WatchConnectivityManager.swift
//  GameNet
//
//  Created by Alliston Aleixo on 07/01/23.
//

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

    @Published var message: [String: Any] = [:]
    @Published var state: WCSessionActivationState = .notActivated

    func activateSession() {
        if WCSession.isSupported() {
            WCSession.default.delegate = WatchConnectivityManager.shared
            WCSession.default.activate()
        }
    }

    func send(message: Any, key: String) throws {
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

        WCSession.default.sendMessage([key: message], replyHandler: nil) { error in
            print("Cannot send message: \(String(describing: error))")
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
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        state = activationState
    }

    #if os(iOS)
        func sessionDidBecomeInactive(_ session: WCSession) {}
        func sessionDidDeactivate(_ session: WCSession) {
            session.activate()
        }
    #endif
}
