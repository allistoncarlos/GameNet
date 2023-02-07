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

    var body: some View {
        NavigationStack(path: $presentedGames) {
            Group {
                ScrollView {
                    LazyVGrid(columns: adaptiveColumns, spacing: 20) {
                        ForEach(viewModel.data, id: \.id) { game in
                            NavigationLink(value: game) {
                                ZStack(alignment: .bottomTrailing) {
                                    AsyncImage(url: URL(string: game.coverURL ?? "")) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    } placeholder: { ProgressView().progressViewStyle(.circular) }
                                    Text(game.name)
                                        .padding(4)
                                        .background(.black)
                                        .foregroundColor(.white)
                                        .offset(x: -5, y: -5)
                                        .font(.system(size: 10))
                                }
                            }
                            .onAppear {
                                Task {
                                    await viewModel.loadNextPage(currentGame: game)
                                }
                            }
                        }
                    }
                }
                .navigationDestination(for: Game.self) { game in
                    if let game, let gameId = game.id {
                        viewModel.showGameDetailView(
                            navigationPath: $presentedGames,
                            gameId: gameId
                        )
                    }
                }
                .searchable(text: $search)
                .onChange(of: search) { search in
                    if search.isEmpty {
                        Task { await viewModel.fetchData(clear: true) }
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
            await viewModel.fetchData()
        }
    }

    // MARK: Private

    @State private var search: String = ""

    private let adaptiveColumns = [
        GridItem(.adaptive(minimum: 120))
    ]

    @State private var presentedGames = NavigationPath()
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
