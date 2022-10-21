//
//  GamesView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import SwiftUI

// MARK: - GamesView

struct GamesView: View {

    // MARK: Internal

    @ObservedObject var viewModel: GamesViewModel

    var body: some View {
        NavigationStack(path: $presentedGames) {
            Group {
                if viewModel.uiState == .loading {
                    ProgressView()
                } else {
                    ScrollView {
                        LazyVGrid(columns: adaptiveColumns, spacing: 20) {
                            ForEach(viewModel.data, id: \.id) { game in
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
                                .onAppear {
                                    Task {
                                        await viewModel.loadNextPage(currentGame: game)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationView(title: "Games")
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
