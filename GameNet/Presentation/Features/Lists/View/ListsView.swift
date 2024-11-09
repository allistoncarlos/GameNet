//
//  ListsView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import GameNet_Network
import SwiftUI
import TTProgressHUD

// MARK: - ListsView

struct ListsView: View {

    // MARK: Internal

    @ObservedObject var viewModel: ListsViewModel
    @State var isLoading = true

    var body: some View {
        NavigationStack(path: $presentedLists) {
            VStack {
                if let lists = viewModel.lists {
                    List(lists, id: \.id) { list in
                        NavigationLink(list.name, value: list.id)
                    }
                }
            }
            .disabled(isLoading)
            .padding(.top, 10)
            .navigationDestination(for: String.self) { listId in
                viewModel.editListView(
                    navigationPath: $presentedLists,
                    listId: listId
                )
            }
            .navigationDestination(for: ListItem.self) { game in
                if let gameId = game.userGameId {
                    viewModel.showGameDetailView(
                        navigationPath: $presentedLists,
                        id: gameId
                    )
                }
            }
            .navigationView(title: "Listas")
            .toolbar {
                Button(action: {}) {
                    NavigationLink(value: String()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .overlay(
            TTProgressHUD($isLoading, config: GameNetApp.hudConfig)
        )
        .onChange(of: viewModel.state) { state in
            isLoading = state == .loading
        }
        .onChange(of: presentedLists) { newValue in
            if newValue.isEmpty {
                Task {
                    await viewModel.fetchData()
                }
            }
        }
        .task {
            await viewModel.fetchData()
        }
    }

    // MARK: Private

    @State private var presentedLists = NavigationPath()
}

// MARK: - Previews

#Preview("Dark Mode") {
    let _ = RepositoryContainer.listRepository.register(factory: { MockListRepository() })

    ListsView(viewModel: ListsViewModel()).preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    let _ = RepositoryContainer.listRepository.register(factory: { MockListRepository() })

    ListsView(viewModel: ListsViewModel()).preferredColorScheme(.light)
}
