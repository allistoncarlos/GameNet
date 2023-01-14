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
        return ListGamesView(viewModel: ListGamesViewModel(originFlow: .finishedByYear(year)))
    }

    static func makeBoughtGamesView(navigationPath: Binding<NavigationPath>, year: Int) -> some View {
        return ListGamesView(viewModel: ListGamesViewModel(originFlow: .boughtByYear(year)))
    }

    static func goBackToDashboard(navigationPath: Binding<NavigationPath>) {
        navigationPath.wrappedValue.removeLast(navigationPath.wrappedValue.count - 1)
    }
}
