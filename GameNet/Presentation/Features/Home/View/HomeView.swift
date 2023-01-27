//
//  HomeView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 30/07/22.
//

import SwiftUI

// MARK: - HomeView

struct HomeView: View {

    // MARK: Lifecycle

    init(
        homeViewModel: HomeViewModel,
        dashboardViewModel: DashboardViewModel,
        platformsViewModel: PlatformsViewModel,
        gamesViewModel: GamesViewModel,
        listsViewModel: ListsViewModel
    ) {
        self.homeViewModel = homeViewModel
        self.dashboardViewModel = dashboardViewModel
        self.platformsViewModel = platformsViewModel
        self.gamesViewModel = gamesViewModel
        self.listsViewModel = listsViewModel
    }

    // MARK: Internal

    @ObservedObject var homeViewModel: HomeViewModel
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @ObservedObject var platformsViewModel: PlatformsViewModel
    @ObservedObject var gamesViewModel: GamesViewModel
    @ObservedObject var listsViewModel: ListsViewModel

    var body: some View {
        TabView {
            DashboardView(viewModel: dashboardViewModel)
                .tabItem {
                    Label("Dashboard", systemImage: "display")
                }
                .navigationBarTitle("Test", displayMode: .inline)

            GamesView(viewModel: gamesViewModel)
                .tabItem {
                    Label("Games", systemImage: "gamecontroller")
                }

            PlatformsView(viewModel: platformsViewModel)
                .tabItem {
                    Label("Plataformas", systemImage: "laptopcomputer")
                }

            ListsView(viewModel: listsViewModel)
                .tabItem {
                    Label("Listas", systemImage: "list.bullet.rectangle.portrait")
                }
        }
        .foregroundColor(.accentColor)
        .navigationViewStyle(.stack)
    }
}

// MARK: - HomeView_Previews

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            let homeViewModel = HomeViewModel()
            let dashboardViewModel = DashboardViewModel()
            let platformsViewModel = PlatformsViewModel()
            let gamesViewModel = GamesViewModel()
            let listsViewModel = ListsViewModel()

            HomeView(
                homeViewModel: homeViewModel,
                dashboardViewModel: dashboardViewModel,
                platformsViewModel: platformsViewModel,
                gamesViewModel: gamesViewModel,
                listsViewModel: listsViewModel
            ).preferredColorScheme($0)
        }
    }
}
