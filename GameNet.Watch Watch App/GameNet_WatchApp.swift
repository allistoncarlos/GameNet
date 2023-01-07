//
//  GameNet_WatchApp.swift
//  GameNet.Watch Watch App
//
//  Created by Alliston Aleixo on 06/01/23.
//

import GameNet_Keychain
import SwiftUI

@main
struct GameNet_Watch_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            PlayingGamesView(viewModel: PlayingGamesViewModel())
        }
    }
}