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
    enum Origin {
        case home
        case lists
    }

    static func makeGameDetailView(navigationPath: Binding<NavigationPath>, gameId: String) -> some View {
        let gameDetailViewModel = GameDetailViewModel(gameId: gameId)

        return GameDetailView(viewModel: gameDetailViewModel, navigationPath: navigationPath)
    }

    static func makeGameEditView(navigationPath: Binding<NavigationPath>, gameId: String?) -> some View {
        let gameEditViewModel = GameEditViewModel(gameId: gameId)

        return GameEditView(viewModel: gameEditViewModel, navigationPath: navigationPath)
    }

    static func makeGameLookupView(
        navigationPath: Binding<NavigationPath>
    ) -> some View {
        let gamesViewModel = GamesViewModel()

        return GamesView(
            viewModel: gamesViewModel,
            origin: Origin.lists,
//            navigationPath: navigationPath
            presentedGames: navigationPath.wrappedValue
        )
    }

    static func goBackToGames(navigationPath: Binding<NavigationPath>) {
        navigationPath.wrappedValue.removeLast()
    }

    static func selectGameList(navigationPath: Binding<NavigationPath>, gameId: String) {
        navigationPath.wrappedValue.removeLast()
    }
}
