//
//  GameplaySessionDetailViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 26/02/23.
//

import Combine
import Factory
import Foundation
import GameNet_Network
import SwiftUI

// MARK: - GameDetailViewModel

@MainActor
class GameplaySessionDetailViewModel: ObservableObject {

    // MARK: Lifecycle

    init(gameplaySession: GameplaySessionNavigation) {
        self.gameplaySession = gameplaySession
    }

    // MARK: Internal

    @Published var gameplaySession: GameplaySessionNavigation
}
