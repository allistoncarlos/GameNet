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
                default:
                    break
                }
            }.store(in: &cancellable)
    }

    // MARK: Internal

    @Published var game: GameDetail? = nil
    @Published var gameplays: GameplaySessions?
    @Published var state: GameDetailState = .idle

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

    // MARK: Private

    private var gameId: String
    @Injected(RepositoryContainer.gameRepository) private var repository
    private var cancellable = Set<AnyCancellable>()
}

extension GameDetailViewModel {
    func goBackToGames(navigationPath: Binding<NavigationPath>) {
        GameRouter.goBackToGames(navigationPath: navigationPath)
    }
}
