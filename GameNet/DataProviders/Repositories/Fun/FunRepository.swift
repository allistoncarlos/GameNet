//
//  FunRepository.swift
//  GameNet
//
//  Created by Alliston Aleixo on 13/06/26.
//

import Factory
import Foundation

// MARK: - FunRepositoryProtocol

protocol FunRepositoryProtocol {
    func fetchRating(userGameId: String) async -> GameFunRating
}

// MARK: - FunRepository

struct FunRepository: FunRepositoryProtocol {

    // MARK: Internal

    func fetchRating(userGameId: String) async -> GameFunRating {
        if let rating = await dataSource.fetchRating(userGameId: userGameId) {
            return rating
        }

        return GameFunRating(average: 5.0, isMock: true)
    }

    // MARK: Private

    @Injected(DataSourceContainer.funDataSource) private var dataSource
}
