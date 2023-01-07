//
//  WatchConnectivityManager.swift
//  GameNet
//
//  Created by Alliston Aleixo on 07/01/23.
//

import Foundation
import WatchConnectivity

// MARK: - NotificationMessage

struct NotificationMessage: Identifiable {
    let id = UUID()
    let text: String
}

// MARK: - WatchConnectivityManager

final class WatchConnectivityManager: NSObject, ObservableObject {

    // MARK: Lifecycle

    override private init() {
        super.init()
    }

    // MARK: Internal

    static let shared = WatchConnectivityManager()

    @Published var notificationMessage: NotificationMessage? = nil

    @Published var state: WCSessionActivationState = .notActivated

    func activateSession() {
        if WCSession.isSupported() {
            WCSession.default.delegate = WatchConnectivityManager.shared
            WCSession.default.activate()
        }
    }

    func send(_ message: Any) {
        let isReachable = WCSession.default.isReachable

//        guard WCSession.default.activationState == .activated else {
//            return
//        }
//        #if os(iOS)
//            guard WCSession.default.isWatchAppInstalled else {
//                return
//            }
//        #else
//            guard WCSession.default.isCompanionAppInstalled else {
//                return
//            }
//        #endif

//        WCSession.default.sendMessage([kMessageKey: message], replyHandler: nil) { error in
//            print("Cannot send message: \(String(describing: error))")
//        }
        do {
            try WCSession.default.updateApplicationContext([kMessageKey: message])
        } catch {
            print("Cannot send message: \(String(describing: error))")
        }
    }

    // MARK: Private

    private let kMessageKey = "message"
}

// MARK: WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let notificationText = message[kMessageKey] as? String {
            DispatchQueue.main.async { [weak self] in
                self?.notificationMessage = NotificationMessage(text: notificationText)
            }
        }
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
