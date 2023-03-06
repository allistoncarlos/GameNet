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
        title = String(gameplaySession.key)

        groupedGameplaySession = Dictionary(
            grouping: gameplaySession.value.sessions,
            by: { $0!.start.dateOnly() }
        )
    }

    // MARK: Internal

    @Published var title: String
    @Published var groupedGameplaySession: [Date: [GameplaySession?]]
}
