//
//  LoginRouter.swift
//  GameNet
//
//  Created by Alliston Aleixo on 30/07/22.
//

import SwiftUI

@MainActor
enum LoginRouter {
    @MainActor
    static func makeHomeView() -> some View {
        let homeViewModel = HomeViewModel()
        let dashboardViewModel = DashboardViewModel()
        let platformsViewModel = PlatformsViewModel()
        let gamesViewModel = GamesViewModel()
        let listsViewModel = ListsViewModel()

        return HomeView(
            homeViewModel: homeViewModel,
            dashboardViewModel: dashboardViewModel,
            platformsViewModel: platformsViewModel,
            gamesViewModel: gamesViewModel,
            listsViewModel: listsViewModel
        )
    }

    static func makeLoginView() -> some View {
        return LoginView(viewModel: LoginViewModel())
    }
}
