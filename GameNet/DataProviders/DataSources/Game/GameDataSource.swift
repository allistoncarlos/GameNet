//
//  GameDataSource.swift
//  GameNet
//
//  Created by Alliston Aleixo on 20/10/22.
//

import Foundation
import GameNet_Network

// MARK: - GameDataSourceProtocol

protocol GameDataSourceProtocol {
    func fetchData(search: String?, page: Int?, pageSize: Int?) async -> PagedList<Game>?
    func fetchData(id: String) async -> GameDetail?
    func fetchGameplaySessions(id: String) async -> GameplaySessions?
}

// MARK: - GameDataSource

class GameDataSource: GameDataSourceProtocol {
    func fetchData(search: String?, page: Int?, pageSize: Int?) async -> PagedList<Game>? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<PagedResult<GameResponse>>.self,
                endpoint: .games(search: search, page: page, pageSize: pageSize)
            ) {
            if apiResult.ok {
                let pagedResult = apiResult.data

                return PagedList<Game>(
                    count: pagedResult.count,
                    totalCount: pagedResult.totalCount,
                    page: pagedResult.page,
                    pageSize: pagedResult.pageSize,
                    totalPages: pagedResult.totalPages,
                    search: pagedResult.search,
                    result: pagedResult.result.compactMap { $0.toGame() }
                )
            }
        }

        return nil
    }

    func fetchData(id: String) async -> GameDetail? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<GameDetailResponse>.self,
                endpoint: .game(id: id)
            ) {
            if apiResult.ok {
                return apiResult.data.toGameDetail()
            }
        }

        return nil
    }

    func fetchGameplaySessions(id: String) async -> GameplaySessions? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<GameplaySessionsResponse>.self,
                endpoint: .gameplays(id: id)
            ) {
            if apiResult.ok {
                return apiResult.data.toGameplaySessions()
            }
        }

        return nil
    }
}
