//
//  GamesView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import GameNet_Network
import SwiftUI
import TTProgressHUD

// MARK: - GamesView

struct GamesView: View {

    // MARK: Internal

    @ObservedObject var viewModel: GamesViewModel
    @State var isLoading = true
    @State var origin: GameRouter.Origin = .home

    var navigationPath: Binding<NavigationPath>? = nil

    var body: some View {
        NavigationStack(path: navigationPath ?? $presentedGames) {
            Group {
                ScrollView {
                    LazyVGrid(columns: adaptiveColumns, spacing: 20) {
                        ForEach(search.isEmpty ? viewModel.data : viewModel.searchedGames, id: \.id) { game in
                            if origin == .home {
                                NavigationLink(value: game.id) {
                                    GameItemView(name: game.name, coverURL: game.coverURL ?? "")
                                }
                                .onAppear {
                                    Task {
                                        await viewModel.loadNextPage(currentGame: game)
                                    }
                                }
                            } else {
                                Button(action: {
                                    if let navigationPath, let gameId = game.id {
                                        viewModel.selectGameList(navigationPath: navigationPath, gameId: gameId)
                                    }
                                }) {
                                    GameItemView(name: game.name, coverURL: game.coverURL ?? "")
                                }
                            }
                        }
                    }
                }
                .navigationDestination(for: String.self) { gameId in
                    viewModel.showGameDetailView(
                        navigationPath: $presentedGames,
                        gameId: gameId
                    )
                }
                .searchable(
                    text: $search,
                    prompt: Text("Buscar")
                )
                .onChange(of: search) { search in
                    if search.isEmpty {
                        Task { await viewModel.fetchData(origin: origin, clear: true) }
                    }
                }
                .onSubmit(of: .search) {
                    Task {
                        await viewModel.fetchData(search: search, clear: true)
                    }
                }
            }
            .disabled(isLoading)
            .navigationView(title: "Games")
            .toolbar {
                Button(action: {}) {
                    NavigationLink {
                        viewModel.showGameEditView(
                            navigationPath: $presentedGames
                        )
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .overlay(
            TTProgressHUD($isLoading, config: GameNetApp.hudConfig)
        )
        .onChange(of: viewModel.state) { state in
            isLoading = state == .loading
        }
        .onChange(of: presentedGames) { newValue in
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

    private let adaptiveColumns = [
        GridItem(.adaptive(minimum: 120))
    ]

    @State var presentedGames = NavigationPath()
}

// MARK: - GamesView_Previews

struct GamesView_Previews: PreviewProvider {
    static var previews: some View {
        let _ = RepositoryContainer.gameRepository.register(factory: { MockGameRepository() })

        ForEach(ColorScheme.allCases, id: \.self) {
            GamesView(viewModel: GamesViewModel()).preferredColorScheme($0)
        }
    }
}
