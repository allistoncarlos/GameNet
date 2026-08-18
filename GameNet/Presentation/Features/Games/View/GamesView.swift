//
//  GamesView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import Factory
import SwiftUI

// MARK: - GamesView

struct GamesView: View {

    // MARK: Internal

    @ObservedObject var viewModel: GamesViewModel
    @State var isLoading = true
    @State var origin: GameRouter.Origin = .home
    @Namespace private var gameCoverTransitionNamespace

    @Binding var selectedUserGameId: String?
    @Binding var isPresented: Bool

    var navigationPath: Binding<NavigationPath>? = nil

    var body: some View {
        NavigationStack(path: navigationPath ?? $presentedGames) {
            GeometryReader { geometry in
                let columns = PlatformMetrics.gameGridColumns(for: geometry.size.width)

                ScrollView {
                    LazyVStack(spacing: 16) {
                        GameListFilterBar(
                            filter: $viewModel.filter,
                            selectedPlatformCount: viewModel.selectedPlatformIds.count,
                            showsPlatformFilter: viewModel.showsPlatformFilter,
                            onPlatformFilterTap: {
                                Task {
                                    await viewModel.fetchPlatforms()
                                    isPlatformFilterPresented = true
                                }
                            }
                        )

                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(displayedGames, id: \.id) { game in
                                gameCell(for: game)
                                    .onAppear {
                                        Task {
                                            await viewModel.loadNextPage(currentGame: game, origin: origin)
                                        }
                                    }
                            }
                        }

                        if !isLoading, displayedGames.isEmpty {
                            Text("Nenhum jogo encontrado")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.top, 24)
                        }
                    }
                    .frame(maxWidth: PlatformMetrics.contentMaxWidth(for: geometry.size.width))
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, PlatformMetrics.horizontalPadding(for: geometry.size.width))
                    .padding(.top, 8)
                }
                .navigationDestination(for: GameDetailRoute.self) { route in
                    viewModel.showGameDetailView(
                        navigationPath: $presentedGames,
                        gameId: route.id,
                        preview: route.preview
                    )
                    .gameDetailZoomTransition(gameId: route.id)
                }
                .searchable(
                    text: $search,
                    prompt: Text("Buscar")
                )
                .onChange(of: search) { _, search in
                    Task {
                        await viewModel.fetchData(origin: origin, search: search, clear: true)
                    }
                }
                .onChange(of: viewModel.filter) { _, _ in
                    Task {
                        await viewModel.fetchData(origin: origin, search: search, clear: true)
                    }
                }
                .onSubmit(of: .search) {
                    Task {
                        await viewModel.fetchData(origin: origin, search: search, clear: true)
                    }
                }
                .refreshable {
                    await viewModel.fetchData(origin: origin, search: search, clear: true)
                }
                .sheet(isPresented: $isPlatformFilterPresented, onDismiss: {
                    Task {
                        await viewModel.fetchData(origin: origin, search: search, clear: true)
                    }
                }) {
                    GamePlatformFilterSheet(
                        platforms: viewModel.platforms,
                        selectedPlatformIds: $viewModel.selectedPlatformIds
                    )
                }
            }
            .disabled(isLoading && displayedGames.isEmpty && search.isEmpty && viewModel.filter == .all && viewModel.selectedPlatformIds.isEmpty)
            .navigationView(title: "Games")
            .toolbar {
                if origin == .home {
                    Button(action: {}) {
                        SwiftUI.NavigationLink {
                            viewModel.showGameEditView(
                                navigationPath: $presentedGames
                            )
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
        .gameCoverTransitionNamespace(gameCoverTransitionNamespace)
        .overlay(
            GameNetProgressHUD($isLoading, config: GameNetApp.hudConfig)
        )
        .onChange(of: viewModel.state) { _, state in
            isLoading = state == .loading
        }
        .onChange(of: presentedGames) { _, newValue in
            if newValue.isEmpty {
                Task {
                    await viewModel.fetchData()
                }
            }
        }
        .task {
            await viewModel.fetchPlatforms()
            await viewModel.fetchData(origin: origin)
        }
    }

    // MARK: Private

    @State private var search: String = ""
    @State private var isPlatformFilterPresented = false
    @State var presentedGames = NavigationPath()

    private var displayedGames: [Game] {
        search.isEmpty ? viewModel.data : viewModel.searchedGames
    }

    @ViewBuilder
    private func gameCell(for game: Game) -> some View {
        if origin == .home {
            if let gameId = game.id {
                SwiftUI.NavigationLink(
                    value: GameDetailRoute(
                        id: gameId,
                        preview: GameDetailPreview(game: game)
                    )
                ) {
                    GameItemView(
                        name: game.name,
                        coverURL: game.coverURL ?? "",
                        gameId: gameId
                    )
                }
            }
        } else {
            Button(action: {
                if let gameId = game.id {
                    selectedUserGameId = gameId
                    isPresented = false
                }
            }) {
                GameItemView(name: game.name, coverURL: game.coverURL ?? "")
            }
        }
    }
}
