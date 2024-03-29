//
//  ListRouter.swift
//  GameNet
//
//  Created by Alliston Aleixo on 10/01/23.
//

import GameNet_Network
import SwiftUI

@MainActor
enum ListRouter {
    static func makeEditListView(navigationPath: Binding<NavigationPath>, list: GameNet_Network.List?) -> some View {
        let emptyList = GameNet_Network.List(id: nil, name: String())
        let editListViewModel = EditListViewModel(list: list ?? emptyList)

        return EditListView(viewModel: editListViewModel, navigationPath: navigationPath)
    }

    static func makeListDetailsView(navigationPath: Binding<NavigationPath>, originFlow: ListOriginFlow) -> some View {
        return ListDetailsView(viewModel: ListDetailsViewModel(originFlow: originFlow), navigationPath: navigationPath)
    }

    static func makeListGamesView(
        navigationPath: Binding<NavigationPath>,
        listGame: ListGame,
        deleteAction: ((IndexSet) -> Void)?,
        moveAction: ((IndexSet, Int) -> Void)?
    ) -> some View {
        let viewModel = ListGamesViewModel(listGame: listGame)

        return ListGamesView(
            viewModel: viewModel,
            deleteAction: deleteAction,
            moveAction: moveAction
        )
    }

    static func makeGameDetailView(navigationPath: Binding<NavigationPath>, id: String)
        -> some View {
        return GameRouter.makeGameDetailView(navigationPath: navigationPath, gameId: id)
    }

    static func makeGameLookupView(
        selectedUserGameId: Binding<String?>,
        isPresented: Binding<Bool>
    ) -> some View {
        return GameRouter.makeGameLookupView(
            selectedUserGameId: selectedUserGameId,
            isPresented: isPresented
        )
    }

    static func goBackToLists(navigationPath: Binding<NavigationPath>) {
        navigationPath.wrappedValue.removeLast()
    }
}
