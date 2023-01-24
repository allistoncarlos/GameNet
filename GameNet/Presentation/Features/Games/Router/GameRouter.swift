//
//  GameRouter.swift
//  GameNet
//
//  Created by Alliston Aleixo on 24/01/23.
//

import GameNet_Network
import SwiftUI

@MainActor
enum GameRouter {
    static func makeGameDetailView(navigationPath: Binding<NavigationPath>, gameId: String) -> some View {
        let gameDetailViewModel = GameDetailViewModel(gameId: gameId)

        return GameDetailView(viewModel: gameDetailViewModel, navigationPath: navigationPath)
    }

    static func goBackToGames(navigationPath: Binding<NavigationPath>) {
        navigationPath.wrappedValue.removeLast()
    }
}
