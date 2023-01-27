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

    var games: [ListItem]? = nil

    var body: some View {
        VStack {
            if let games {
                List(games, id: \.userGameId) { game in
                    GamesListItemView(game: game)
                }
            } else {
                Text("EMPTY")
            }
        }
    }
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
