//
//  ListsViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 10/01/23.
//

import Combine
import Factory
import Foundation
import GameNet_Network
import SwiftUI

// MARK: - PlatformsViewModel

@MainActor
class ListsViewModel: ObservableObject {

    // MARK: Lifecycle

    init() {
        $state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
                case let .success(lists):
                    self?.lists = lists
                default:
                    break
                }
            }.store(in: &cancellable)
    }

    // MARK: Internal

    @Published var lists: [GameNet_Network.List]? = nil
    @Published var state: ListsState = .idle

    func fetchData(cache: Bool = true) async {
        state = .loading

        let result = await repository.fetchData(cache: cache)

        if let result {
            state = .success(result)
        } else {
            state = .error("Erro no carregamento de dados do servidor")
        }
    }

    // MARK: Private

    @Injected(RepositoryContainer.listRepository) private var repository
    private var cancellable = Set<AnyCancellable>()
}

extension ListsViewModel {
    func editListView(navigationPath: Binding<NavigationPath>, listId: String? = nil) -> some View {
        let list = lists?.first(where: { $0.id == listId })

        return ListRouter.makeEditListView(navigationPath: navigationPath, list: list)
    }
    
    func showGameDetailView(navigationPath: Binding<NavigationPath>, id: String) -> some View {
        return ListRouter.makeGameDetailView(navigationPath: navigationPath, id: id)
    }
}
