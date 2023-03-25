//
//  GameEditViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 21/03/23.
//

import Combine
import Factory
import Foundation
import GameNet_Network
import SwiftUI

// MARK: - GameEditViewModel

@MainActor
class GameEditViewModel: ObservableObject {

    // MARK: Lifecycle

    init(gameId: String? = nil) {
        self.gameId = gameId
        isNewGame = gameId == nil

        $state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.handleViewModelState(state)
            }.store(in: &cancellable)
    }

    // MARK: Internal

    @Published var isNewGame: Bool
    @Published var platforms: [Platform] = []
    @Published var state: GameEditState = .idle
    
    @Published var game: UserGameModel = .init()

    func fetchData() async {
        state = .loading

        let platforms = await platformRepository.fetchData()

        if let platforms {
            state = .loadedPlatforms(platforms)
        } else {
            state = .error("Erro na busca de dados do jogo no servidor")
        }
    }

    // MARK: Private

    private var gameId: String?
    @Injected(RepositoryContainer.gameRepository) private var repository
    @Injected(RepositoryContainer.platformRepository) private var platformRepository
    private var cancellable = Set<AnyCancellable>()

    private func handleViewModelState(_ state: GameEditState) {
        switch state {
        case let .loadedPlatforms(platforms):
            if let platforms {
                self.platforms = platforms
            }
        default:
            break
        }
    }

}

extension GameEditViewModel {
    func goBackToGames(navigationPath: Binding<NavigationPath>) {
        GameRouter.goBackToGames(navigationPath: navigationPath)
    }
}
