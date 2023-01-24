//
//  GameNet_WatchApp.swift
//  GameNet.Watch Watch App
//
//  Created by Alliston Aleixo on 06/01/23.
//

import Combine
import GameNet_Keychain
import SwiftUI
import WatchConnectivity

@main
struct GameNet_Watch_Watch_AppApp: App {

    // MARK: Internal

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: HomeViewModel())
                .onAppear {
                    WatchConnectivityManager.shared.activateSession()
                }
        }
    }

    // MARK: Private

    private var cancellables = Set<AnyCancellable>()
}
