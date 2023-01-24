//
//  DashboardRouter.swift
//  GameNet
//
//  Created by Alliston Aleixo on 14/01/23.
//

import GameNet_Network
import SwiftUI

@MainActor
enum DashboardRouter {
    static func makeFinishedGamesView(navigationPath: Binding<NavigationPath>, year: Int) -> some View {
        return ListRouter.makeListDetailsView(navigationPath: navigationPath, originFlow: .finishedByYear(year))
    }

    static func makeBoughtGamesView(navigationPath: Binding<NavigationPath>, year: Int) -> some View {
        return ListRouter.makeListDetailsView(navigationPath: navigationPath, originFlow: .boughtByYear(year))
    }
    
    static func makeGameDetailView(navigationPath: Binding<NavigationPath>, id: String) -> some View {
        return GameRouter.makeGameDetailView(navigationPath: navigationPath, gameId: id)
    }

    static func goBackToDashboard(navigationPath: Binding<NavigationPath>) {
        navigationPath.wrappedValue.removeLast(navigationPath.wrappedValue.count - 1)
    }
}
