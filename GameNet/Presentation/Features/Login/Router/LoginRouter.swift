//
//  LoginRouter.swift
//  GameNet
//
//  Created by Alliston Aleixo on 30/07/22.
//

import SwiftUI

@MainActor
enum LoginRouter {
    static func makeHomeView() -> some View {
        let homeViewModel = HomeViewModel()
        let dashboardViewModel = DashboardViewModel()
        let platformsViewModel = PlatformsViewModel()
        let gamesViewModel = GamesViewModel()

        return HomeView(
            homeViewModel: homeViewModel,
            dashboardViewModel: dashboardViewModel,
            platformsViewModel: platformsViewModel,
            gamesViewModel: gamesViewModel
        )
    }

    static func makeLoginView() -> some View {
        return LoginView(viewModel: LoginViewModel())
    }
}
