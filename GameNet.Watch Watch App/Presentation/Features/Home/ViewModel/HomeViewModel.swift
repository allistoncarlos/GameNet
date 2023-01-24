//
//  HomeViewModel.swift
//  GameNet.Watch Watch App
//
//  Created by Alliston Aleixo on 10/01/23.
//

import Combine
import Foundation
import GameNet_Keychain

class HomeViewModel: ObservableObject {

    // MARK: Lifecycle

    init() {
        hasValidAccessToken = KeychainDataSource.hasValidToken()
    }

    // MARK: Internal

    @Published var hasValidAccessToken: Bool = false
    @Published var state: HomeConnectivityState = .idle

    func askForCredentials() {
        if !KeychainDataSource.hasValidToken() {
            state = .askingForCredentials

            WatchConnectivityManager.shared.$message
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] message in
                    print("[WATCH SESSION] - MESSAGE KEYS: \(message.keys) - \(message.count)")
                    if message["NOT_LOGGED"] != nil {
                        self?.state = .notLogged
                    } else if let authInfo = message["AUTH_INFO"] as? [String] {
                        DispatchQueue.main.async {
                            let id = authInfo[0]
                            let accessToken = authInfo[1]
                            let refreshToken = authInfo[2]
                            let expiresIn = authInfo[3]

                            KeychainDataSource.id.set(id)
                            KeychainDataSource.accessToken.set(accessToken)
                            KeychainDataSource.refreshToken.set(refreshToken)
                            KeychainDataSource.expiresIn.set(expiresIn)

                            self?.state = .logged
                        }
                    }
                })
                .store(in: &cancellables)

            var watchConnectivityManagerState = WatchConnectivityManager.shared.state

            while watchConnectivityManagerState != .activated {
                watchConnectivityManagerState = WatchConnectivityManager.shared.state
            }

            WatchConnectivityManager.shared.sendMessage(
                message: "ASK_FOR_CREDENTIALS_MESSAGE",
                key: "ASK_FOR_CREDENTIALS"
            )
        } else {
            self.state = .logged
        }
    }

    // MARK: Private

    private var cancellables = Set<AnyCancellable>()

}
