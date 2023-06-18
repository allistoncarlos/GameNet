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

    static func makeGameEditView(navigationPath: Binding<NavigationPath>, gameId: String?) -> some View {
        let gameEditViewModel = GameEditViewModel(gameId: gameId)

        return GameEditView(viewModel: gameEditViewModel, navigationPath: navigationPath)
    }
    
    static func makeGameLookupView(navigationPath: Binding<NavigationPath>) -> some View {
        let gamesViewModel = GamesViewModel()
        
        return GamesView(viewModel: gamesViewModel)
    }

    static func goBackToGames(navigationPath: Binding<NavigationPath>) {
        navigationPath.wrappedValue.removeLast()
    }
}
