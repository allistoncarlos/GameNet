//
//  GameNet_WatchApp.swift
//  GameNet.Watch Watch App
//
//  Created by Alliston Aleixo on 06/01/23.
//

import SwiftUI

@main
struct GameNet_Watch_Watch_AppApp: App {
    init() {
        WatchConnectivityManager.shared.activateSession()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
