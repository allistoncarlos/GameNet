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
            if let listGame = viewModel.listGame {
                if let games = listGame.games {
                    GamesListView(games: games)
                }
            }
        }
    }

    // MARK: Private

    @State private var presentedLists = NavigationPath()
}
