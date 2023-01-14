//
//  ListGamesViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 11/01/23.
//

import Combine
import Factory
import Foundation
import GameNet_Network
import SwiftUI

// MARK: - ListGamesViewModel

@MainActor
class ListGamesViewModel: ObservableObject {

    // MARK: Lifecycle

    init(listId: String? = nil, originFlow: ListOriginFlow? = nil) {
        self.listId = listId
        self.originFlow = originFlow

        $state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
                case let .success(listGame):
                    self?.listGame = listGame
                default:
                    break
                }
            }.store(in: &cancellable)
    }

    // MARK: Internal

    var listId: String?
    var originFlow: ListOriginFlow?

    @Published var listGame: ListGame? = nil
    @Published var state: ListGamesState = .idle

    func fetchData() async {
        state = .loading

        if let listId {
            let result = await repository.fetchData(id: listId)

            if let result {
                state = .success(result)
            } else {
                state = .error("Erro no carregamento de dados do servidor")
            }
        } else if let originFlow {
            switch originFlow {
            case let .finishedByYear(year):
                let result = await repository.fetchFinishedByYearData(id: year)

                if let result {
                    let listGame = ListGame(id: String(year), name: String(year), games: result)
                    state = .success(listGame)
                } else {
                    state = .error("Erro no carregamento de dados do servidor")
                }
            case let .boughtByYear(year):
                let result = await repository.fetchBoughtByYearData(id: year)

                if let result {
                    let listGame = ListGame(id: String(year), name: String(year), games: result)
                    state = .success(listGame)
                } else {
                    state = .error("Erro no carregamento de dados do servidor")
                }
            }
        }
    }

    // MARK: Private

    @Injected(RepositoryContainer.listRepository) private var repository
    private var cancellable = Set<AnyCancellable>()
}

// extension EditListViewModel {
//    func goBackToLists(navigationPath: Binding<NavigationPath>) {
//        ListRouter.goBackToLists(navigationPath: navigationPath)
//    }
// }
