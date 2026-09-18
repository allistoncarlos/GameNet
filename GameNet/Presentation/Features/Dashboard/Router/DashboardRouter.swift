//
//  DashboardRouter.swift
//  GameNet
//
//  Created by Alliston Aleixo on 14/01/23.
//

import SwiftUI

// MARK: - DashboardRouter

@MainActor
enum DashboardRouter {
    static func makeFinishedGamesView(navigationPath: Binding<NavigationPath>, year: Int) -> some View {
        return ListRouter.makeListDetailsView(navigationPath: navigationPath, originFlow: .finishedByYear(year))
    }

    static func makeBoughtGamesView(navigationPath: Binding<NavigationPath>, year: Int) -> some View {
        return ListRouter.makeListDetailsView(navigationPath: navigationPath, originFlow: .boughtByYear(year))
    }

    static func makeGameDetailView(
        navigationPath: Binding<NavigationPath>,
        id: String,
        preview: GameDetailPreview? = nil
    ) -> some View {
        return GameRouter.makeGameDetailView(navigationPath: navigationPath, gameId: id, preview: preview)
    }

    static func makeGameplaySessionDetailView(
        navigationPath: Binding<NavigationPath>,
        gameplaySession: GameplaySessionNavigation
    ) -> some View {
        GameplaySessionDetailView(
            viewModel: GameplaySessionDetailViewModel(gameplaySession: gameplaySession),
            navigationPath: navigationPath
        )
    }

    static func goBackToDashboard(navigationPath: Binding<NavigationPath>) {
        navigationPath.wrappedValue.removeLast(navigationPath.wrappedValue.count - 1)
    }
}

// MARK: - GameplaySessionNavigation

struct GameplaySessionNavigation: Hashable {
    var key: Int
    var value: GameplaySessions
}
