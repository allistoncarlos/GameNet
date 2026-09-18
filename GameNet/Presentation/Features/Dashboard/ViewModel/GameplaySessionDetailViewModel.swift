//
//  GameplaySessionDetailViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 26/02/23.
//

import Combine
import Factory
import Foundation
import SwiftUI

// MARK: - BarShape

struct BarShape: Identifiable {
    var type: String
    var sortDate: Date
    var count: Double
    var id = UUID()
}

// MARK: - GameplaySessionDay

/// Sessões de um dia, já ordenadas — montado uma vez no init do view model em vez
/// de agrupar/ordenar o dicionário a cada renderização da lista.
struct GameplaySessionDay: Identifiable {
    let date: Date
    let sessions: [GameplaySession]

    var id: Date { date }
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

        days = gameplaySessions
            .map { date, sessions in
                GameplaySessionDay(
                    date: date,
                    sessions: sessions
                        .compactMap { $0 }
                        .sorted(by: { $0.start > $1.start })
                )
            }
            .sorted(by: { $0.date > $1.date })

        // Descobrir menor data
        guard let minDate = gameplaySessions.keys.min() else {
            chartGameplaySession = []
            recentRegister = nil
            return
        }

        let calendar = Calendar.current
        let today = Date().dateOnly()
        let sessionsYear = calendar.component(.year, from: minDate)

        // 31 de dezembro do ano das sessões — sem isso, um ano passado ganhava
        // dias zerados até hoje e as abas S/M/6M/A misturavam anos diferentes.
        let endOfYearComponents = DateComponents(year: sessionsYear, month: 12, day: 31)
        let endOfYear = calendar.date(from: endOfYearComponents)!.dateOnly()

        // Regra: no ano corrente vai até hoje; nos anteriores, até 31/12
        let maxDate = today < endOfYear ? today : endOfYear

        // Gerar todas as datas do intervalo
        var allDates: [Date] = []
        var currentDate = minDate

        while currentDate <= maxDate {
            allDates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        // Criar os BarShapes
        let chartSessions: [BarShape] = allDates.map { date in
            if let sessions = gameplaySessions[date] {
                let intervals = sessions.map { values in
                    guard
                        let finish = values?.finish,
                        let start = values?.start else { return Double(0) }

                    return (finish - start) / 60
                }

                let totalInterval: TimeInterval = intervals.reduce(0, +)

                return BarShape(
                    type: date.toFormattedString(dateFormat: GameNetApp.shortDateFormat),
                    sortDate: date,
                    count: totalInterval
                )
            } else {
                // Dia sem registro
                return BarShape(
                    type: date.toFormattedString(dateFormat: GameNetApp.shortDateFormat),
                    sortDate: date,
                    count: 0
                )
            }
        }

        chartGameplaySession = chartSessions
        recentRegister = chartSessions.last?.id
    }

    // MARK: Internal

    @Published var title: String
    @Published var days: [GameplaySessionDay]
    @Published var chartGameplaySession: [BarShape]
    @Published var recentRegister: UUID?
}
