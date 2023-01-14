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
        navigationPath.wrappedValue.append(list?.id)

        return EditListView(viewModel: editListViewModel, navigationPath: navigationPath)
    }

    static func makeListDetailsView(navigationPath: Binding<NavigationPath>, originFlow: ListOriginFlow) -> some View {
        return ListDetailsView(viewModel: ListDetailsViewModel(originFlow: originFlow), navigationPath: navigationPath)
    }

    static func goBackToLists(navigationPath: Binding<NavigationPath>) {
        navigationPath.wrappedValue.removeLast(navigationPath.wrappedValue.count - 1)
    }
}
