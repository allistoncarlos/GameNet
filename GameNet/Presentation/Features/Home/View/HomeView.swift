//
//  HomeView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 30/07/22.
//

import SwiftUI

// MARK: - HomeSection

private enum HomeSection: String, CaseIterable, Identifiable {
    case dashboard
    case games
    case platforms
    case lists

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .games: return "Games"
        case .platforms: return "Plataformas"
        case .lists: return "Listas"
        }
    }

    var icon: String {
        switch self {
        case .dashboard: return "display"
        case .games: return "gamecontroller"
        case .platforms: return "laptopcomputer"
        case .lists: return "list.bullet.rectangle.portrait"
        }
    }
}

// MARK: - HomeView

struct HomeView: View {

    init(
        homeViewModel: HomeViewModel,
        dashboardViewModel: DashboardViewModel,
        platformsViewModel: PlatformsViewModel,
        gamesViewModel: GamesViewModel,
        listsViewModel: ListsViewModel,
        serverDrivenPlatformsViewModel: ServerDrivenPlatformsViewModel
    ) {
        self.homeViewModel = homeViewModel
        self.dashboardViewModel = dashboardViewModel
        self.platformsViewModel = platformsViewModel
        self.gamesViewModel = gamesViewModel
        self.listsViewModel = listsViewModel
        self.serverDrivenPlatformsViewModel = serverDrivenPlatformsViewModel
    }

    @ObservedObject var homeViewModel: HomeViewModel
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @ObservedObject var platformsViewModel: PlatformsViewModel
    @ObservedObject var gamesViewModel: GamesViewModel
    @ObservedObject var listsViewModel: ListsViewModel
    @ObservedObject var serverDrivenPlatformsViewModel: ServerDrivenPlatformsViewModel

    #if os(macOS)
    @State private var selectedSection: HomeSection = .dashboard
    #endif

    var body: some View {
        #if os(macOS)
        TabView(selection: $selectedSection) {
            DashboardView(viewModel: dashboardViewModel)
                .tag(HomeSection.dashboard)
                .tabItem { Label("Dashboard", systemImage: "display") }

            GamesView(
                viewModel: gamesViewModel,
                selectedUserGameId: .constant(nil),
                isPresented: .constant(false)
            )
            .tag(HomeSection.games)
            .tabItem { Label("Games", systemImage: "gamecontroller") }

            platforms
                .tag(HomeSection.platforms)
                .tabItem { Label("Plataformas", systemImage: "laptopcomputer") }

            ListsView(viewModel: listsViewModel)
                .tag(HomeSection.lists)
                .tabItem { Label("Listas", systemImage: "list.bullet.rectangle") }
        }
        .tabViewStyle(.automatic)
        .foregroundColor(.accentColor)
        .macOSWindowStyle()
        #else
        TabView {
            DashboardView(viewModel: dashboardViewModel)
                .tabItem {
                    Label("Dashboard", systemImage: "display")
                }

            GamesView(
                viewModel: gamesViewModel,
                selectedUserGameId: .constant(nil),
                isPresented: .constant(false)
            )
            .tabItem {
                Label("Games", systemImage: "gamecontroller")
            }

            platforms
                .tabItem {
                    Label("Plataformas", systemImage: "laptopcomputer")
                }

            ListsView(viewModel: listsViewModel)
                .tabItem {
                    Label("Listas", systemImage: "list.bullet.rectangle")
                }
        }
        .foregroundColor(.accentColor)
        .navigationViewStyle(.stack)
        #endif
    }

    @ViewBuilder private var platforms: some View {
        FirebaseRemoteConfig.serverDrivenPlatforms ?
            AnyView(ServerDrivenPlatformsView(viewModel: serverDrivenPlatformsViewModel)) :
            AnyView(PlatformsView(viewModel: platformsViewModel))
    }
}

#Preview("Dark Mode") {
    let homeViewModel = HomeViewModel()
    let dashboardViewModel = DashboardViewModel()
    let platformsViewModel = PlatformsViewModel()
    let gamesViewModel = GamesViewModel()
    let listsViewModel = ListsViewModel()
    let serverDrivenPlatformsViewModel = ServerDrivenPlatformsViewModel()

    HomeView(
        homeViewModel: homeViewModel,
        dashboardViewModel: dashboardViewModel,
        platformsViewModel: platformsViewModel,
        gamesViewModel: gamesViewModel,
        listsViewModel: listsViewModel,
        serverDrivenPlatformsViewModel: serverDrivenPlatformsViewModel
    ).preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    let homeViewModel = HomeViewModel()
    let dashboardViewModel = DashboardViewModel()
    let platformsViewModel = PlatformsViewModel()
    let gamesViewModel = GamesViewModel()
    let listsViewModel = ListsViewModel()
    let serverDrivenPlatformsViewModel = ServerDrivenPlatformsViewModel()

    HomeView(
        homeViewModel: homeViewModel,
        dashboardViewModel: dashboardViewModel,
        platformsViewModel: platformsViewModel,
        gamesViewModel: gamesViewModel,
        listsViewModel: listsViewModel,
        serverDrivenPlatformsViewModel: serverDrivenPlatformsViewModel
    ).preferredColorScheme(.light)
}
