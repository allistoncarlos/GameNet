//
//  GameDetailViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 24/01/23.
//

import Combine
import Factory
import Foundation
import GameNet_Network
import SwiftUI

// MARK: - GameDetailViewModel

@MainActor
class GameDetailViewModel: ObservableObject {

    // MARK: Lifecycle

    init(gameId: String) {
        self.gameId = gameId

        $state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
                case let .successGame(game):
                    self?.game = game

                    if let gameId = game.id {
                        Task {
                            await self?.fetchGameplaySessions(id: gameId)
                        }
                    }
                case let .successGameplays(gameplays):
                    self?.gameplays = gameplays
                    self?.updateStarted()
                case .successSave:
                    Task {
                        await self?.fetchGameplaySessions(id: gameId)
                    }
                default:
                    break
                }
            }.store(in: &cancellable)
    }

    // MARK: Internal

    @Published var game: GameDetail? = nil
    @Published var gameplays: GameplaySessions?
    @Published var latestGameplaySession: GameplaySession?
    @Published var state: GameDetailState = .idle
    @Published var isStarted: Bool = false

    func fetchData() async {
        state = .loading

        let result = await repository.fetchData(id: gameId)

        if let result {
            state = .successGame(result)
        } else {
            state = .error("Erro na busca de dados do jogo no servidor")
        }
    }

    func fetchGameplaySessions(id: String) async {
        state = .loading

        if let result = await repository.fetchGameplaySessions(id: id) {
            state = .successGameplays(result)
        } else {
            state = .error("Erro na busca de dados de sessões no servidor")
        }
    }
    
    func save() async {
        state = .loading
        
        var start = Date.timeZoneDate()
        
        if isStarted {
            if let latestStart = self.latestGameplaySession?.start {
                start = latestStart
            }
        }
        
        let finish = isStarted ? Date.timeZoneDate() : nil

        let result = await gameplaySessionRepository.save(
            userGameId: self.gameId,
            start: start,
            finish: finish,
            id: nil
        )
        
        if let result {
            state = .successSave(result)
        } else {
            state = .error("Erro no salvamento de dados do servidor")
        }
    }

    // MARK: Private

    private var gameId: String
    @Injected(RepositoryContainer.gameRepository) private var repository
    @Injected(RepositoryContainer.gameplaySessionRepository) private var gameplaySessionRepository
    private var cancellable = Set<AnyCancellable>()
    
    private func updateStarted() {
        if let gameplays {
            let ordered = gameplays.sessions.sorted(by: { lhs, rhs in
                if let lhsDate = lhs?.finish,
                   let rhsDate = rhs?.finish {
                    
                    return lhsDate < rhsDate
                }
                
                return true
            })
            
            if ordered.contains(where: { gameplaySession in
                gameplaySession?.finish == nil
            }) {
                isStarted = true
            } else if let latestGameplaySession = ordered.last, let latestGameplaySession {
                self.latestGameplaySession = latestGameplaySession
                isStarted = latestGameplaySession.finish == nil
            }
        }
    }
}

extension GameDetailViewModel {
    func goBackToGames(navigationPath: Binding<NavigationPath>) {
        GameRouter.goBackToGames(navigationPath: navigationPath)
    }
}
