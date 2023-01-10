//
//  GameRepository.swift
//  GameNet
//
//  Created by Alliston Aleixo on 20/10/22.
//

import Factory
import Foundation
import GameNet_Network

// MARK: - GameRepositoryProtocol

protocol GameRepositoryProtocol {
    func fetchData(search: String?, page: Int?, pageSize: Int?) async -> PagedList<Game>?
}

// MARK: - GameRepository

struct GameRepository: GameRepositoryProtocol {

    // MARK: Internal

    func fetchData(search: String?, page: Int?, pageSize: Int?) async -> PagedList<Game>? {
        return await dataSource.fetchData(search: search, page: page, pageSize: pageSize)
    }

    // MARK: Private

    @Injected(DataSourceContainer.gameDataSource) private var dataSource
}
