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
    var deleteAction: ((IndexSet) -> Void)?

    var body: some View {
        if let games {
            ForEach(games) { game in
                GamesListItemView(game: game)
            }
            .onDelete(perform: deleteItems)
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        deleteAction?(offsets)
    }
}

// MARK: - GamesListView_Previews

struct GamesListView_Previews: PreviewProvider {
    static var previews: some View {
        let listGame = MockListRepository().fetchData(id: "1")

        GamesListView(games: listGame?.games)
    }
}
