//
//  GamesViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 20/10/22.
//

import Combine
import Factory
import Foundation
import SwiftUI

// MARK: - GamesViewModel

@MainActor
class GamesViewModel: ObservableObject {

    // MARK: Lifecycle

    init(platformId: String? = nil) {
        self.platformId = platformId
    }

    // MARK: Internal

    let platformId: String?
    @Published var filter: GameListFilter = .all
    @Published var selectedPlatformIds: Set<String> = []
    @Published var platforms: [Platform] = []
    @Published var pagedList: PagedList<Game>? = nil
    @Published var data: [Game] = []
    @Published var searchedGames: [Game] = []
    @Published var state: GamesState = .idle

    var showsPlatformFilter: Bool { platformId == nil }

    func fetchPlatforms() async {
        guard showsPlatformFilter, platforms.isEmpty else { return }

        let result = await platformRepository.fetchData()
        platforms = result ?? []
    }

    func fetchData(
        origin _: GameRouter.Origin = .home,
        search: String? = "",
        page: Int = 0,
        clear: Bool = false
    ) async {
        if clear {
            data = []
            searchedGames = []
            currentPage = 0
            isFetchingNextPage = false
            canLoadMore = true
            fetchGeneration += 1
        }

        let generation = fetchGeneration
        let isPaging = !clear && page > 0
        if !isPaging {
            state = .loading
        }

        isFetchingNextPage = true
        let pagedList = await fetchPagedGames(search: search, page: page)

        guard generation == fetchGeneration else { return }

        isFetchingNextPage = false

        if let pagedList {
            self.pagedList = pagedList
            currentPage = pagedList.page ?? page
            canLoadMore = !pagedList.result.isEmpty && displayedCount(for: search) < pagedList.totalCount

            if let search, !search.isEmpty {
                searchedGames += pagedList.result
            } else {
                data += pagedList.result
            }

            state = .success
        } else {
            canLoadMore = false
            state = .error("Erro no carregamento de dados do servidor")
        }
    }

    func loadNextPage(currentGame: Game, origin: GameRouter.Origin = .home) async {
        guard !isFetchingNextPage else { return }
        guard hasMorePages else { return }

        let games = displayedGames
        guard let index = games.firstIndex(where: { $0.id == currentGame.id }) else { return }

        let threshold = max(games.count - 5, 0)
        guard index >= threshold else { return }

        await fetchData(
            origin: origin,
            search: pagedList?.search,
            page: currentPage + 1
        )
    }

    // MARK: Private

    @Injected(\.gameRepository) private var repository
    @Injected(\.platformRepository) private var platformRepository
    private var cancellable = Set<AnyCancellable>()
    private var isFetchingNextPage = false
    private var currentPage = 0
    private var canLoadMore = true
    private var fetchGeneration = 0

    private var displayedGames: [Game] {
        displayedList(for: pagedList?.search)
    }

    private var hasMorePages: Bool {
        canLoadMore && displayedGames.count < (pagedList?.totalCount ?? 0)
    }

    private func displayedList(for search: String?) -> [Game] {
        let query = search ?? ""
        return query.isEmpty ? data : searchedGames
    }

    private func displayedCount(for search: String?) -> Int {
        displayedList(for: search).count
    }

    private var effectivePlatformIds: [String] {
        if let platformId {
            return [platformId]
        }

        return selectedPlatformIds.sorted()
    }

    private func fetchPagedGames(search: String?, page: Int) async -> PagedList<Game>? {
        let platformIds = effectivePlatformIds

        if platformIds.count <= 1 {
            return await repository.fetchData(
                search: search,
                page: page,
                pageSize: GameNetApp.pageSize,
                platformId: platformIds.first,
                gameType: filter.queryValue
            )
        }

        return await fetchGamesForMultiplePlatforms(
            platformIds: platformIds,
            search: search,
            page: page
        )
    }

    private func fetchGamesForMultiplePlatforms(
        platformIds: [String],
        search: String?,
        page: Int
    ) async -> PagedList<Game>? {
        let pageSize = GameNetApp.pageSize

        var results: [PagedList<Game>] = []
        results.reserveCapacity(platformIds.count)

        for platformId in platformIds {
            if let result = await repository.fetchData(
                search: search,
                page: page,
                pageSize: pageSize,
                platformId: platformId,
                gameType: filter.queryValue
            ) {
                results.append(result)
            }
        }

        guard !results.isEmpty else { return nil }

        var seenIds = Set<String>()
        let merged = results
            .flatMap(\.result)
            .filter { game in
                guard let id = game.id else { return true }
                return seenIds.insert(id).inserted
            }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        return PagedList<Game>(
            count: merged.count,
            totalCount: results.reduce(0) { $0 + $1.totalCount },
            page: page,
            pageSize: pageSize,
            totalPages: results.map(\.totalPages).max() ?? 1,
            search: search,
            result: merged
        )
    }
}

extension GamesViewModel {
    func showGameDetailView(
        navigationPath: Binding<NavigationPath>,
        gameId: String,
        preview: GameDetailPreview? = nil
    ) -> some View {
        return GameRouter.makeGameDetailView(navigationPath: navigationPath, gameId: gameId, preview: preview)
    }

    func showGameEditView(
        navigationPath: Binding<NavigationPath>,
        gameId: String? = nil
    ) -> some View {
        return GameRouter.makeGameEditView(navigationPath: navigationPath, gameId: gameId)
    }
}
