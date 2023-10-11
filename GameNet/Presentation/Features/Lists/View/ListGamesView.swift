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
    var deleteAction: ((IndexSet) -> Void)?

    var body: some View {
        if let listGame = viewModel.listGame {
            if let games = listGame.games {
                GamesListView(games: games, deleteAction: deleteAction)
            }
        }
    }

    // MARK: Private

    @State private var presentedLists = NavigationPath()
}

// MARK: - ListGames_Previews

struct ListGames_Previews: PreviewProvider {
    static var previews: some View {
        let listGame = MockListRepository().fetchData(id: "1")
        ListGamesView(viewModel: ListGamesViewModel(listGame: listGame!))
    }
}
