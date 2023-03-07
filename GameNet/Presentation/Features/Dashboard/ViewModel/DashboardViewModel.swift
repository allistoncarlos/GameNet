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
                case let .successGameplay(year, gameplaySessions):
                    self?.gameplaySessions?[year] = gameplaySessions
                default:
                    break
                }
            }.store(in: &cancellable)
    }

    // MARK: Internal

    @Published var dashboard: Dashboard? = nil
    @Published var gameplaySessions: [Int: GameplaySessions]? = nil
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
        let lastYear = Calendar.current.component(.year, from: Date())

        for year in initialYear ... lastYear {
            let result = await gameplaySessionRepository.fetchGameplaySessionsByYear(year: year, month: nil)

            if let result {
                state = .successGameplay(year, result)
            } else {
                state = .error("Erro no carregamento de dados do servidor")
            }
        }
    }

    // MARK: Private

    @Injected(RepositoryContainer.dashboardRepository) private var repository
    @Injected(RepositoryContainer.gameplaySessionRepository) private var gameplaySessionRepository
    private var cancellable = Set<AnyCancellable>()
}

extension DashboardViewModel {
    func showFinishedGamesView(navigationPath: Binding<NavigationPath>, year: Int) -> some View {
        return DashboardRouter.makeFinishedGamesView(navigationPath: navigationPath, year: year)
    }

    func showBoughtGamesView(navigationPath: Binding<NavigationPath>, year: Int) -> some View {
        return DashboardRouter.makeBoughtGamesView(navigationPath: navigationPath, year: year)
    }

    func showGameDetailView(navigationPath: Binding<NavigationPath>, id: String) -> some View {
        return DashboardRouter.makeGameDetailView(navigationPath: navigationPath, id: id)
    }
    
    func showGameplaySessionDetailView(navigationPath: Binding<NavigationPath>, gameplaySession: GameplaySessionNavigation) -> some View {
        return DashboardRouter.makeGameplaySessionDetailView(
            navigationPath: navigationPath,
            gameplaySession: gameplaySession
        )
    }
}
