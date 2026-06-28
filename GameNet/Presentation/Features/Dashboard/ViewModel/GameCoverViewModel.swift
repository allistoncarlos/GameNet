//
//  GameCoverViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 14/11/24.
//

import Foundation
import Combine
import GameNet_Network
import Factory

@MainActor
class GameCoverViewModel: ObservableObject {
    @Published var isStarted: Bool = false
    
    init(playingGame: PlayingGame) {
        self.playingGame = playingGame
        self.updateStarted()
        
        $state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
                case let .success(gameplaySession):
                    self?.playingGame.latestGameplaySession = LatestGameplaySession(
                        id: gameplaySession.id,
                        userGameId: gameplaySession.userGameId,
                        start: gameplaySession.start,
                        finish: gameplaySession.finish
                    )
                    
                    self?.updateStarted()
                default:
                    break
                }
            }.store(in: &cancellable)
    }

    @Published var playingGame: PlayingGame
    @Published var state: GameCoverState = .idle

    /// Retorna `true` quando o dashboard deve ser recarregado (ao iniciar uma nova gameplay).
    @discardableResult
    func save() async -> Bool {
        state = .loading

        let wasStarted = isStarted
        var start = Date.timeZoneDate()
        
        if isStarted {
            if let latestStart = playingGame.latestGameplaySession?.start {
                start = latestStart
            }
        }
        
        let finish = isStarted ? Date.timeZoneDate() : nil

        guard let playingGameId = playingGame.id else {
            state = .error("Erro no processamento de dados")
            return false
        }

        let result = await repository.save(
            userGameId: playingGameId,
            start: start,
            finish: finish,
            id: nil
        )

        if let result {
            state = .success(result)
            return !wasStarted
        } else {
            state = .error("Erro no salvamento de dados do servidor")
            return false
        }
    }

    /// Retorna `true` quando o dashboard deve ser recarregado (sucesso ao zerar o jogo).
    @discardableResult
    func finishGame() async -> Bool {
        state = .loading

        guard let playingGameId = playingGame.id else {
            state = .error("Erro no processamento de dados")
            return false
        }

        let success = await repository.finishGame(userGameId: playingGameId)

        if success {
            isStarted = false
            state = .idle
            return true
        } else {
            state = .error("Erro ao finalizar o jogo")
            return false
        }
    }

    /// Retorna `true` quando o dashboard deve ser recarregado (sucesso ao parar de jogar).
    @discardableResult
    func dropGameplay() async -> Bool {
        state = .loading

        guard let playingGameId = playingGame.id else {
            state = .error("Erro no processamento de dados")
            return false
        }

        let success = await repository.dropGameplay(userGameId: playingGameId)

        if success {
            isStarted = false
            state = .idle
            return true
        } else {
            state = .error("Erro ao parar de jogar")
            return false
        }
    }

    // MARK: Private
    @Injected(RepositoryContainer.gameplaySessionRepository) private var repository
    private var cancellable = Set<AnyCancellable>()
    
    private func updateStarted() {
        if let latestGameplaySession = playingGame.latestGameplaySession {
            isStarted = latestGameplaySession.finish == nil
        }
    }
}
