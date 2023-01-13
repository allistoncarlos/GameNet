//
//  EditListViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 11/01/23.
//

import Combine
import Factory
import Foundation
import GameNet_Network
import SwiftUI

// MARK: - EditListViewModel

@MainActor
class EditListViewModel: ObservableObject {

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
    @Published var state: EditListState = .idle

    func save() async {
        state = .loading

        let result = await repository.saveList(id: list.id, list: List(id: list.id, name: list.name))

        if let result {
            state = .success(result)
        } else {
            state = .error("Erro no salvamento de dados do servidor")
        }
    }

    // MARK: Private

    @Injected(RepositoryContainer.listRepository) private var repository
    private var cancellable = Set<AnyCancellable>()
}

extension EditListViewModel {
    func goBackToLists(navigationPath: Binding<NavigationPath>) {
        ListRouter.goBackToLists(navigationPath: navigationPath)
    }
}