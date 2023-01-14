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
