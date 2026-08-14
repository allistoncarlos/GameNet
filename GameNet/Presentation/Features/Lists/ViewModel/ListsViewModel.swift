//
//  ListsViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 10/01/23.
//

import Combine
import Factory
import Foundation
import SwiftUI

// MARK: - ListsViewModel

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

    @Published var lists: [GameNet.List]? = nil
    @Published var listCards: [ListCardModel] = []
    @Published var state: ListsState = .idle

    func fetchData(cache: Bool = true) async {
        state = .loading

        let result = await repository.fetchData(cache: cache)

        if let result {
            lists = result
            listCards = result.map { ListCardModel(list: $0, games: []) }
            state = .success(result)
            await fetchListPreviews(for: result, cache: cache)
        } else {
            state = .error("Erro no carregamento de dados do servidor")
        }
    }

    // MARK: Private

    @Injected(\.listRepository) private var repository
    private var cancellable = Set<AnyCancellable>()

    private func fetchListPreviews(for lists: [GameNet.List], cache: Bool) async {
        await withTaskGroup(of: (String, [ListItem]).self) { group in
            for list in lists {
                guard let id = list.id else { continue }

                group.addTask {
                    let games = await self.repository.fetchData(id: id, cache: cache)?.games ?? []
                    let orderedGames = games.sorted { ($0.order ?? 0) < ($1.order ?? 0) }
                    return (id, orderedGames)
                }
            }

            for await (id, games) in group {
                if let index = listCards.firstIndex(where: { $0.list.id == id }) {
                    listCards[index].games = games
                }

                CoverImageCache.prefetch(
                    urls: games.prefix(3).compactMap(\.cover)
                )
            }
        }
    }
}

extension ListsViewModel {
    func editListView(navigationPath: Binding<NavigationPath>, listId: String? = nil) -> some View {
        let list = lists?.first(where: { $0.id == listId })

        return ListRouter.makeEditListView(navigationPath: navigationPath, list: list)
    }
    
    func showGameDetailView(
        navigationPath: Binding<NavigationPath>,
        id: String,
        preview: GameDetailPreview? = nil
    ) -> some View {
        return ListRouter.makeGameDetailView(navigationPath: navigationPath, id: id, preview: preview)
    }
}
