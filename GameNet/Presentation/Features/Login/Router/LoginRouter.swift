//
//  LoginRouter.swift
//  GameNet
//
//  Created by Alliston Aleixo on 30/07/22.
//

import SwiftUI
import SwiftData

@MainActor
enum LoginRouter {
    static func makeHomeView(modelContext: ModelContext) -> some View {
        let homeViewModel = HomeViewModel(modelContext: modelContext)
        let dashboardViewModel = DashboardViewModel()
        let platformsViewModel = PlatformsViewModel(modelContext: modelContext)
        let gamesViewModel = GamesViewModel()
        let listsViewModel = ListsViewModel()

        let serverDrivenPlatformsViewModel = ServerDrivenPlatformsViewModel()

        return HomeView(
            homeViewModel: homeViewModel,
            dashboardViewModel: dashboardViewModel,
            platformsViewModel: platformsViewModel,
            gamesViewModel: gamesViewModel,
            listsViewModel: listsViewModel,
            
            serverDrivenPlatformsViewModel: serverDrivenPlatformsViewModel
        )
    }

    static func makeLoginView() -> some View {
        return LoginView(viewModel: LoginViewModel())
    }
}
