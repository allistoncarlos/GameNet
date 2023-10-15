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
import GameNet_Keychain

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
                case let .loadedGames(listGame):
                    self?.listGame = listGame
                case let .success(list):
                    self?.list = list
                default:
                    break
                }
            }.store(in: &cancellable)
    }

    // MARK: Internal

    @Published var list: GameNet_Network.List
    @Published var listGame: ListGame = ListGame(id: "", name: "", games: [])
    @Published var state: EditListState = .idle

    func fetchGames() async {
        if let listId = list.id {
            state = .loading

            let result = await repository.fetchData(id: listId)

            if let result {
                state = .loadedGames(result)
            } else {
                state = .error("Erro no carregamento de dados do servidor")
            }
        }
    }

    func save() async {
        state = .loading
        
        let userId = KeychainDataSource.id.get()
        let result = await repository.saveList(id: list.id, userId: userId, list: listGame)
        
        if let result {
            state = .success(result)
        } else {
            state = .error("Erro no salvamento de dados do servidor")
        }
    }

    func addUserGame(selectedUserGameId: Binding<String?>) async {
        if let selectedUserGameIdWrapped = selectedUserGameId.wrappedValue {
            state = .loading
            
            let result = await gameRepository.fetchData(id: selectedUserGameIdWrapped)

            if let result {
                let listItem = ListItem(
                    id: result.id,
                    name: result.name,
                    platform: result.platform,
                    userGameId: result.id,
                    year: nil,
                    boughtDate: nil,
                    value: nil,
                    start: nil,
                    finish: nil,
                    cover: result.cover,
                    order: nil,
                    comment: nil
                )

                listGame.games?.append(listItem)
            }

            state = .idle
        }
    }
    
    func delete(at offsets: IndexSet) {
        listGame.games?.remove(atOffsets: offsets)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        listGame.games?.move(fromOffsets: source, toOffset: destination)
    }

    // MARK: Private

    @Injected(RepositoryContainer.listRepository) private var repository
    @Injected(RepositoryContainer.gameRepository) private var gameRepository
    private var cancellable = Set<AnyCancellable>()
}

extension EditListViewModel {
    func showListGamesView(
        navigationPath: Binding<NavigationPath>,
        listGame: ListGame,
        deleteAction: ((IndexSet) -> Void)?,
        moveAction: ((IndexSet, Int) -> Void)?
    ) -> some View {
        return ListRouter.makeListGamesView(
            navigationPath: navigationPath,
            listGame: listGame,
            deleteAction: deleteAction,
            moveAction: moveAction
        )
    }

    func showGameDetailView(navigationPath: Binding<NavigationPath>, id: String) -> some View {
        return ListRouter.makeGameDetailView(navigationPath: navigationPath, id: id)
    }

    func showGameLookupView(
        selectedUserGameId: Binding<String?>,
        isPresented: Binding<Bool>
    ) -> some View {
        return ListRouter.makeGameLookupView(
            selectedUserGameId: selectedUserGameId,
            isPresented: isPresented
        )
    }

    func goBackToLists(navigationPath: Binding<NavigationPath>) {
        ListRouter.goBackToLists(navigationPath: navigationPath)
    }
}
