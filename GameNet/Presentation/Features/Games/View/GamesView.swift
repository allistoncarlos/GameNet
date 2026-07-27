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
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(search.isEmpty ? viewModel.data : viewModel.searchedGames, id: \.id) { game in
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
                                    .onAppear {
                                        Task {
                                            await viewModel.loadNextPage(currentGame: game)
                                        }
                                    }
                                }
                            } else {
                                Button(action: {
                                    if let gameId = game.id {
                                        self.selectedUserGameId = gameId
                                        self.isPresented = false
                                    }
                                }) {
                                    GameItemView(name: game.name, coverURL: game.coverURL ?? "")
                                }
                            }
                        }
                    }
                    .frame(maxWidth: PlatformMetrics.contentMaxWidth(for: geometry.size.width))
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, PlatformMetrics.horizontalPadding(for: geometry.size.width))
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
                    if search.isEmpty {
                        Task { await viewModel.fetchData(origin: origin, clear: true) }
                    }
                }
                .onSubmit(of: .search) {
                    Task {
                        await viewModel.fetchData(search: search, clear: true)
                    }
                }
                .refreshable {
                    Task {
                        await viewModel.fetchData(origin: origin)
                    }
                }
            }
            .disabled(isLoading)
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
            await viewModel.fetchData(origin: origin)
        }
    }

    // MARK: Private

    @State private var search: String = ""
    @State var presentedGames = NavigationPath()
}

// MARK: - Previews

#Preview("Dark Mode") {
    let _ = Container.shared.gameRepository.register(factory: { MockGameRepository() })
    
    GamesView(
        viewModel: GamesViewModel(),
        selectedUserGameId: .constant(nil),
        isPresented: .constant(false)
    ).preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    let _ = Container.shared.gameRepository.register(factory: { MockGameRepository() })
    
    GamesView(
        viewModel: GamesViewModel(),
        selectedUserGameId: .constant(nil),
        isPresented: .constant(false)
    ).preferredColorScheme(.light)
}
