//
//  ListsView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import Factory
import SwiftUI

// MARK: - ListsView

struct ListsView: View {

    // MARK: Internal

    @ObservedObject var viewModel: ListsViewModel
    @State var isLoading = true
    @Namespace private var gameCoverTransitionNamespace

    var body: some View {
        NavigationStack(path: $presentedLists) {
            GeometryReader { geometry in
                ScrollView {
                    if !viewModel.listCards.isEmpty {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.listCards) { card in
                                SwiftUI.NavigationLink(value: card.list.id ?? "") {
                                    ListCardView(model: card)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(maxWidth: PlatformMetrics.contentMaxWidth(for: geometry.size.width))
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, PlatformMetrics.horizontalPadding(for: geometry.size.width))
                        .padding(.vertical, 8)
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
                        id: gameId,
                        preview: GameDetailPreview(listItem: game)
                    )
                    .gameDetailZoomTransition(gameId: gameId)
                }
            }
            .navigationView(title: "Listas")
            .toolbar {
                Button(action: {}) {
                    SwiftUI.NavigationLink(value: String()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .gameCoverTransitionNamespace(gameCoverTransitionNamespace)
        .overlay(
            GameNetProgressHUD($isLoading, config: GameNetApp.hudConfig)
        )
        .onChangeCompat(of: viewModel.state) { state in
            isLoading = state == .loading
        }
        .onChangeCompat(of: presentedLists.isEmpty) { isEmpty in
            if isEmpty {
                Task {
                    await viewModel.fetchData()
                }
            }
        }
        .refreshable {
            Task {
                await viewModel.fetchData()
            }
        }
        .task {
            await viewModel.fetchData()
        }
    }

    // MARK: Private

    @State private var presentedLists = NavigationPath()
}
