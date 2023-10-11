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

// MARK: - BarShape

struct BarShape: Identifiable {
    var type: String
    var sortDate: Date
    var count: Double
    var id = UUID()
}

// MARK: - GameplaySessionDetailViewModel

@MainActor
class GameplaySessionDetailViewModel: ObservableObject {

    // MARK: Lifecycle

    init(gameplaySession: GameplaySessionNavigation) {
        title = String(gameplaySession.key)

        let gameplaySessions = Dictionary(
            grouping: gameplaySession.value.sessions,
            by: { $0!.start.dateOnly() }
        )

        groupedGameplaySession = gameplaySessions

        let chartSessions = gameplaySessions.map { gameplaySession in
            let intervals = gameplaySession.value.map { values in
                guard
                    let finish = values?.finish,
                    let start = values?.start else { return Double(0) }

                return (finish - start) / 60
            }

            let totalInterval: TimeInterval = intervals.reduce(0, +)

            return BarShape(
                type: gameplaySession.key.toFormattedString(dateFormat: GameNetApp.shortDateFormat),
                sortDate: gameplaySession.key,
                count: totalInterval
            )
        }

        chartGameplaySession = chartSessions
        recentRegister = chartSessions.last?.id
    }

    // MARK: Internal

    @Published var title: String
    @Published var groupedGameplaySession: [Date: [GameplaySession?]]
    @Published var chartGameplaySession: [BarShape]
    @Published var recentRegister: UUID?
}
