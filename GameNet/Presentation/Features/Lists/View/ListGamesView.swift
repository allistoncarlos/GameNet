//
//  ListGamesView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 11/01/23.
//

import GameNet_Network
import SwiftUI

// MARK: - ListGamesView

struct ListGamesView: View {

    // MARK: Internal

    @ObservedObject var viewModel: ListGamesViewModel

    var body: some View {
        NavigationStack(path: $presentedLists) {
            VStack {
                if viewModel.state == .loading {
                    ProgressView()
                } else {
                    if let listGame = viewModel.listGame {
                        if let games = listGame.games {
                            GamesListView(games: games)
                        }
                    }
                }
            }
        }
        .onChange(of: presentedLists) { newValue in
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

    @State private var presentedLists = NavigationPath()
}

// MARK: - ListGamesView_Previews

struct ListGamesView_Previews: PreviewProvider {
    static var previews: some View {
        let _ = RepositoryContainer.listRepository.register(factory: { MockListRepository() })

        let viewModel = ListGamesViewModel(listId: "1")
        Task { await viewModel.fetchData() }

        return ListGamesView(
            viewModel: viewModel
        )
    }
}
