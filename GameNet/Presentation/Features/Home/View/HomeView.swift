//
//  HomeView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 30/07/22.
//

import SwiftUI
import SwiftData
import GameNet_Network

// MARK: - HomeView

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext

    // MARK: Lifecycle

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

    // MARK: Internal
    @ObservedObject var homeViewModel: HomeViewModel
    @ObservedObject var dashboardViewModel: DashboardViewModel
    @ObservedObject var platformsViewModel: PlatformsViewModel
    @ObservedObject var gamesViewModel: GamesViewModel
    @ObservedObject var listsViewModel: ListsViewModel
    
    @ObservedObject var serverDrivenPlatformsViewModel: ServerDrivenPlatformsViewModel

    var body: some View {
        TabView {
            DashboardView(viewModel: dashboardViewModel)
                .tabItem {
                    Label("Dashboard", systemImage: "display")
                }
            // TODO: tvOS
//                .navigationBarTitle("Test", displayMode: .inline)

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
                    Label("Listas", systemImage: "list.bullet.rectangle.portrait")
                }
        }
        .foregroundColor(.accentColor)
        .navigationViewStyle(.stack)
    }

    @ViewBuilder private var platforms: some View {
        FirebaseRemoteConfig.serverDrivenPlatforms ?
            AnyView(ServerDrivenPlatformsView(viewModel: serverDrivenPlatformsViewModel)) :
            AnyView(PlatformsView(viewModel: platformsViewModel))
    }
}

// MARK: - Previews

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    
    let persistentModels: [any PersistentModel.Type] = [
        Platform.self,
        GameNet_Network.List.self
    ]
    
    let modelContext = ModelContext(
        try! ModelContainer(for: Schema(persistentModels), configurations: config)
    )
    
    let homeViewModel = HomeViewModel(modelContext: modelContext)
    let dashboardViewModel = DashboardViewModel()
    let platformsViewModel = PlatformsViewModel(modelContext: modelContext)
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
    )
    .modelContainer(
        for: persistentModels,
        inMemory: true
    )
    .preferredColorScheme(.dark)
}
