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

    func save() async {
        state = .loading
        
        var start = Date.timeZoneDate()
        
        if isStarted {
            if let latestStart = playingGame.latestGameplaySession?.start {
                start = latestStart
            }
        }
        
        let finish = isStarted ? Date.timeZoneDate() : nil

        if let playingGameId = playingGame.id {
            let result = await repository.save(
                userGameId: playingGameId,
                start: start,
                finish: finish,
                id: nil
            )
            
            if let result {
                state = .success(result)
            } else {
                state = .error("Erro no salvamento de dados do servidor")
            }
        } else {
            state = .error("Erro no processamento de dados")
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
