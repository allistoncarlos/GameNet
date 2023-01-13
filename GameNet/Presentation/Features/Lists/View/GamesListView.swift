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

    var games: [Game]? = nil

    var body: some View {
        NavigationStack(path: $presentedGames) {
            VStack {
                if let games {
                    List(games, id: \.id) { game in
                        // TODO: PROVAVELMENTE, COLOCAR AQUI A CÉLULA
                        NavigationLink(game.name, value: game.id)
                    }
                } else {
                    Text("EMPTY")
                }
            }
            .navigationDestination(for: String.self) { listId in
//                viewModel.editListView(navigationPath: $presentedGames, listId: listId)
            }
        }
    }

    // MARK: Private

    @State private var presentedGames = NavigationPath()
}

// MARK: - GamesListView_Previews

struct GamesListView_Previews: PreviewProvider {
    static var previews: some View {
        GamesListView()
    }
}
