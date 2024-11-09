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
    var moveAction: ((IndexSet, Int) -> Void)?

    var body: some View {
        if let listGame = viewModel.listGame {
            if let games = listGame.games {
                GamesListView(
                    games: games,
                    deleteAction: deleteAction,
                    moveAction: moveAction
                )
            }
        }
    }

    // MARK: Private

    @State private var presentedLists = NavigationPath()
}

// MARK: - Previews

#Preview("Dark Mode") {
    let listGame = MockListRepository().fetchData(id: "1")
    ListGamesView(viewModel: ListGamesViewModel(listGame: listGame!)).preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    let listGame = MockListRepository().fetchData(id: "1")
    ListGamesView(viewModel: ListGamesViewModel(listGame: listGame!)).preferredColorScheme(.light)
}
