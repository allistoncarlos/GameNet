//
//  GamesViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 20/10/22.
//

import Combine
import Factory
import Foundation
import GameNet_Network
import SwiftUI

// MARK: - GamesViewModel

@MainActor
class GamesViewModel: ObservableObject {

    // MARK: Internal

    @Published var pagedList: PagedList<Game>? = nil
    @Published var data: [Game] = []
    @Published var searchedGames: [Game] = []
    @Published var state: GamesState = .idle

    func fetchData(search: String? = "", page: Int = 0) async {
        state = .loading

        let pagedList = await repository.fetchData(search: search, page: page, pageSize: GameNetApp.pageSize)

        if let pagedList {
            self.pagedList = pagedList
            data += pagedList.result

            state = .success
        } else {
            state = .error("Erro no carregamento de dados do servidor")
        }
    }

    func loadNextPage(currentGame: Game) async {
        let thresholdIndex = data.index(data.endIndex, offsetBy: -5)

        if data.firstIndex(where: { $0.id == currentGame.id }) == thresholdIndex {
            let page = pagedList?.page ?? 0
            await fetchData(search: pagedList?.search, page: page + 1)
        }
    }

    // MARK: Private

    @Injected(RepositoryContainer.gameRepository) private var repository
    private var cancellable = Set<AnyCancellable>()
}

extension GamesViewModel {
    func showGameDetailView(navigationPath: Binding<NavigationPath>, gameId: String) -> some View {
        return GameRouter.makeGameDetailView(navigationPath: navigationPath, gameId: gameId)
    }
}
