//
//  ListGamesViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 11/01/23.
//

import Combine
import Factory
import Foundation
import GameNet_Network
import SwiftUI

// MARK: - ListGamesViewModel

@MainActor
class ListGamesViewModel: ObservableObject {

    // MARK: Lifecycle

    init(listGame: ListGame) {
        self.listGame = listGame
    }

    // MARK: Internal

    var listId: String?
    var originFlow: ListOriginFlow?

    @Published var listGame: ListGame? = nil
}

extension ListGamesViewModel {
    func goBackToLists(navigationPath: Binding<NavigationPath>) {
        ListRouter.goBackToLists(navigationPath: navigationPath)
    }
}
