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

    init(list: GameNet_Network.List) {
        self.list = list

        $state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
                case let .success(list):
                    self?.list = list
                default:
                    break
                }
            }.store(in: &cancellable)
    }

    // MARK: Internal

    @Published var list: GameNet_Network.List
    @Published var state: ListGamesState = .idle

    func fetchData() async {
        state = .loading

        let result = await repository.fetchData()

        if let result {
            // TODO: ORGANIZAR ISSO AQUI
            state = .success(result.first!)
        } else {
            state = .error("Erro no carregamento de dados do servidor")
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
