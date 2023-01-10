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
        WatchConnectivityManager.shared.$message
            .receive(on: RunLoop.main)
            .sink(receiveValue: { message in
                if let id = message["ID"] as? String {
                    DispatchQueue.main.async {
                        KeychainDataSource.id.set(id)
                    }
                }

                if let accessToken = message["ACCESS_TOKEN"] as? String {
                    DispatchQueue.main.async {
                        KeychainDataSource.accessToken.set(accessToken)
                    }
                }

                if let refreshToken = message["REFRESH_TOKEN"] as? String {
                    DispatchQueue.main.async {
                        KeychainDataSource.refreshToken.set(refreshToken)
                    }
                }

                if let expiresIn = message["EXPIRES_IN"] as? String {
                    DispatchQueue.main.async {
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
