//
//  DashboardViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 22/08/22.
//

import Combine
import Factory
import Foundation
import GameNet_Network
import SwiftUI

// MARK: - AnnualGameplayProgressSeries

struct AnnualGameplayProgressSeries: Identifiable {
    let year: Int
    let points: [AnnualGameplayProgressPoint]
    let totalMinutes: Double

    var id: Int { year }
}

// MARK: - AnnualGameplayProgressPoint

struct AnnualGameplayProgressPoint: Identifiable {
    let year: Int
    let day: Int
    let date: Date
    let referenceDate: Date
    let cumulativeMinutes: Double

    var id: String {
        "\(year)-\(day)"
    }

    var yearLabel: String { String(year) }
    var dayLabel: String { referenceDate.toFormattedString(dateFormat: "dd/MM") }
    var value: Double { cumulativeMinutes }
}

// MARK: - DashboardViewModel

@MainActor
class DashboardViewModel: ObservableObject {

    // MARK: Lifecycle

    init() {
        $state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
                case let .success(dashboard):
                    self?.dashboard = dashboard
                    self?.gameplaySessions = [:]
                    self?.annualGameplayProgress = []
                case let .successGameplay(year, gameplaySessions):
                    self?.gameplaySessions?[year] = gameplaySessions
                    self?.annualGameplayProgress = Self.makeAnnualGameplayProgress(
                        gameplaySessionsByYear: self?.gameplaySessions ?? [:]
                    )
                default:
                    break
                }
            }.store(in: &cancellable)
    }

    // MARK: Internal

    @Published var dashboard: Dashboard? = nil
    @Published var gameplaySessions: [Int: GameplaySessions]? = nil
    @Published var annualGameplayProgress: [AnnualGameplayProgressSeries] = []
    @Published var state: DashboardState = .idle

    func fetchData() async {
        state = .loading

        let result = await repository.fetchData()

        if let result {
            state = .success(result)
            await fetchGameplaySessionsByYear()
        } else {
            state = .error("Erro no carregamento de dados do servidor")
        }
    }

    func fetchGameplaySessionsByYear() async {
        state = .loading

        let initialYear = 2020
        let lastYear = Calendar.current.component(.year, from: Date.timeZoneDate())

        await withTaskGroup(of: GameplaySessions?.self) { group in
            for year in initialYear ... lastYear {
                group.addTask {
                    await self.gameplaySessionRepository.fetchGameplaySessionsByYear(year: year, month: nil)
                }
            }

            for await result in group {
                if let firstDate = result?.sessions[0]?.start {
                    let year = Calendar.current.component(.year, from: firstDate)
                    if let result {
                        state = .successGameplay(year, result)
                    } else {
                        state = .error("Erro no carregamento de dados do servidor")
                    }
                }
            }
        }
    }

    // MARK: Private

    @Injected(RepositoryContainer.dashboardRepository) private var repository
    @Injected(RepositoryContainer.gameplaySessionRepository) private var gameplaySessionRepository
    private var cancellable = Set<AnyCancellable>()
}

extension DashboardViewModel {
    static func makeAnnualGameplayProgress(
        gameplaySessionsByYear: [Int: GameplaySessions],
        currentDate: Date = Date.timeZoneDate(),
        calendar: Calendar = .current
    ) -> [AnnualGameplayProgressSeries] {
        let currentYear = calendar.component(.year, from: currentDate)

        guard currentYear >= 2021 else {
            return []
        }

        return (2021 ... currentYear).map { year in
            let sessions = gameplaySessionsByYear[year]?.sessions.compactMap { $0 } ?? []
            let gameplayMinutesByDay = Dictionary(grouping: sessions, by: { $0.start.dateOnly() })
                .mapValues { sessions in
                    sessions.reduce(0.0) { partialResult, session in
                        guard let finish = session.finish else {
                            return partialResult
                        }

                        return partialResult + max(0, (finish - session.start) / 60)
                    }
                }

            guard
                let startDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
                let endDate = comparisonEndDate(for: year, currentDate: currentDate, calendar: calendar)
            else {
                return AnnualGameplayProgressSeries(year: year, points: [], totalMinutes: 0)
            }

            var points: [AnnualGameplayProgressPoint] = []
            var cumulativeMinutes = 0.0
            var currentPointDate = startDate.dateOnly()
            var day = 1

            while currentPointDate <= endDate {
                cumulativeMinutes += gameplayMinutesByDay[currentPointDate] ?? 0

                if let referenceDate = referenceDate(for: currentPointDate, referenceYear: currentYear, calendar: calendar) {
                    points.append(
                        AnnualGameplayProgressPoint(
                            year: year,
                            day: day,
                            date: currentPointDate,
                            referenceDate: referenceDate,
                            cumulativeMinutes: cumulativeMinutes
                        )
                    )
                }

                guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentPointDate) else {
                    break
                }

                currentPointDate = nextDate.dateOnly()
                day += 1
            }

            return AnnualGameplayProgressSeries(
                year: year,
                points: points,
                totalMinutes: cumulativeMinutes
            )
        }
    }

    private static func comparisonEndDate(
        for year: Int,
        currentDate: Date,
        calendar: Calendar
    ) -> Date? {
        let monthDayComponents = calendar.dateComponents([.month, .day], from: currentDate)

        if let exactDate = calendar.date(
            from: DateComponents(
                year: year,
                month: monthDayComponents.month,
                day: monthDayComponents.day
            )
        ) {
            return exactDate.dateOnly()
        }

        guard let month = monthDayComponents.month else {
            return nil
        }

        return calendar.date(
            from: DateComponents(
                year: year,
                month: month + 1,
                day: 0
            )
        )?.dateOnly()
    }

    private static func referenceDate(
        for date: Date,
        referenceYear: Int,
        calendar: Calendar
    ) -> Date? {
        let components = calendar.dateComponents([.month, .day], from: date)

        return calendar.date(
            from: DateComponents(
                year: referenceYear,
                month: components.month,
                day: components.day
            )
        )?.dateOnly()
    }
}

extension DashboardViewModel {
    func showFinishedGamesView(navigationPath: Binding<NavigationPath>, year: Int) -> some View {
        return DashboardRouter.makeFinishedGamesView(navigationPath: navigationPath, year: year)
    }

    func showBoughtGamesView(navigationPath: Binding<NavigationPath>, year: Int) -> some View {
        return DashboardRouter.makeBoughtGamesView(navigationPath: navigationPath, year: year)
    }

    func showGameDetailView(
        navigationPath: Binding<NavigationPath>,
        id: String,
        preview: GameDetailPreview? = nil
    ) -> some View {
        return DashboardRouter.makeGameDetailView(navigationPath: navigationPath, id: id, preview: preview)
    }

    func showGameplaySessionDetailView(navigationPath: Binding<NavigationPath>, gameplaySession: GameplaySessionNavigation) -> some View {
        return DashboardRouter.makeGameplaySessionDetailView(
            navigationPath: navigationPath,
            gameplaySession: gameplaySession
        )
    }
    
    #if os(iOS) && DEBUG
    func featureToggle() -> some View {
        return DashboardRouter.makeFeatureToggle()
    }

    func metabaseDashboard() -> some View {
        return DashboardRouter.makeMetabaseDashboard()
    }
    #endif
}
