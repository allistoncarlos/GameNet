//
//  GamesListView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 11/01/23.
//

import GameNet_Network
import SwiftUI

// MARK: - GamesListView

struct GamesListView: View {

    // MARK: Internal

    var games: [ListItem]? = nil

    var body: some View {
//        NavigationStack(path: $presentedGames) {
        VStack {
            if let games {
                List(games, id: \.userGameId) { game in
                    GamesListItemView(game: game)
                }
            } else {
                Text("EMPTY")
            }
//            }
//            .navigationDestination(for: String.self) { listId in
            ////                viewModel.editListView(navigationPath: $presentedGames, listId: listId)
//            }
        }
    }

    // MARK: Private

    @State private var presentedGames = NavigationPath()
}

// MARK: - GamesListView_Previews

struct GamesListView_Previews: PreviewProvider {
    static var previews: some View {
        let listGame = MockListRepository().fetchData(id: "1")

        GamesListView(
            games: listGame?.games
        )
    }
}
