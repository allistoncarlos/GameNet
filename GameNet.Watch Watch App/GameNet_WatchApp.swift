//
//  GameNet_WatchApp.swift
//  GameNet.Watch Watch App
//
//  Created by Alliston Aleixo on 06/01/23.
//

import Combine
import GameNet_Keychain
import SwiftUI

@main
struct GameNet_Watch_Watch_AppApp: App {

    // MARK: Lifecycle

    init() {
        WatchConnectivityManager.shared.$context
            .receive(on: RunLoop.main)
            .sink(receiveValue: { context in
                if let authInfo = context["AUTH_INFO"] as? [String] {
                    DispatchQueue.main.async {
                        let id = authInfo[0]
                        let accessToken = authInfo[1]
                        let refreshToken = authInfo[2]
                        let expiresIn = authInfo[3]

                        KeychainDataSource.id.set(id)
                        KeychainDataSource.accessToken.set(accessToken)
                        KeychainDataSource.refreshToken.set(refreshToken)
                        KeychainDataSource.expiresIn.set(expiresIn)
                    }
                }
            })
            .store(in: &cancellables)

        WatchConnectivityManager.shared.activateSession()
    }

    // MARK: Internal

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: HomeViewModel())
        }
    }

    // MARK: Private

    private var cancellables = Set<AnyCancellable>()
}
