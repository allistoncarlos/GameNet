//
//  GameEditViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 21/03/23.
//

import Combine
import Factory
import Foundation
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
    @Published var selectedImageData: Data? = nil
    @Published var isImportPresented = false
    @Published var importQuery = ""
    @Published var importResults: [TheGamesDBGame] = []
    @Published var isImporting = false
    @Published var importMessage: String?

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

    func save() async {
        state = .loading

        if let selectedImageData,
           let gameData = game.toGameData(cover: selectedImageData),
           let userGameData = game.toUserGameData() {
            let saved = await repository.save(
                data: gameData,
                userGameData: userGameData
            )

            if saved {
                state = .saved
            } else {
                state = .error("Erro ao salvar o jogo")
            }
        } else {
            state = .error("Erro ao retornar objeto de jogo")
        }
    }

    func openImport() {
        importQuery = game.name
        importResults = []
        importMessage = nil
        isImportPresented = true
    }

    func searchImport() async {
        let name = importQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        guard catalogRepository.hasAPIKey else {
            importMessage = "Configure THEGAMESDB_API_KEY no Config.xcconfig."
            importResults = []
            return
        }

        isImporting = true
        importMessage = nil
        let coverName = game.platform.map { PlatformCoverResolver.parse($0.name).coverSearchName }
        importResults = await catalogRepository.searchGames(name: name, coverPlatformName: coverName)
        if importResults.isEmpty {
            importMessage = "Nenhum jogo encontrado na TheGamesDB."
        }
        isImporting = false
    }

    func applyImport(_ catalogGame: TheGamesDBGame) async {
        isImporting = true
        importMessage = nil

        guard let boxartURL = await catalogRepository.boxartURL(gameId: catalogGame.id),
              let data = await catalogRepository.downloadImage(from: boxartURL) else {
            importMessage = "Não foi possível baixar a boxart."
            isImporting = false
            return
        }

        game.name = catalogGame.name
        selectedImageData = data
        isImporting = false
        isImportPresented = false
    }

    // MARK: Private

    private var gameId: String?
    @Injected(\.gameRepository) private var repository
    @Injected(\.platformRepository) private var platformRepository
    @Injected(\.theGamesDBRepository) private var catalogRepository
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
