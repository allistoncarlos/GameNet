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
}

// MARK: - GameDataSource

class GameDataSource: GameDataSourceProtocol {
    func fetchData(search: String?, page: Int?, pageSize: Int?) async -> PagedList<Game>? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<PagedResult<GameResponse>>.self,
                endpoint: .games(search: search, page: page, pageSize: pageSize)
            ) {
//            if apiResult.ok {
//                return apiResult.data.toGame()
//            }

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

//    func fetchData(id: String) async -> Platform? {
//        if let apiResult = await NetworkManager.shared
//            .performRequest(
//                responseType: APIResult<PlatformResponse>.self,
//                endpoint: .platform(id: id)
//            ) {
//            if apiResult.ok {
//                return apiResult.data.toPlatform()
//            }
//        }
//
//        return nil
//    }
//
//    func savePlatform(id: String?, platform: Platform) async -> Platform? {
//        if let apiResult = await NetworkManager.shared
//            .performRequest(
//                responseType: APIResult<PlatformResponse>.self,
//                endpoint: .savePlatform(id: id, data: platform.toRequest())
//            ) {
//            if apiResult.ok {
//                return apiResult.data.toPlatform()
//            }
//        }
//
//        return nil
//    }
}
