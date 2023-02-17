//
//  GameplaySessionRepository.swift
//  GameNet
//
//  Created by Alliston Aleixo on 17/02/23.
//

import Factory
import Foundation
import GameNet_Network

// MARK: - GameplaySessionRepositoryProtocol

protocol GameplaySessionRepositoryProtocol {
    func fetchGameplaySessionsByYear(year: Int, month: Int?) async -> GameplaySessions?
}

// MARK: - GameplaySessionRepository

struct GameplaySessionRepository: GameplaySessionRepositoryProtocol {

    // MARK: Internal

    func fetchGameplaySessionsByYear(year: Int, month: Int? = nil) async -> GameplaySessions? {
        return await dataSource.fetchGameplaySessionsByYear(year: year, month: month)
    }

    // MARK: Private

    @Injected(DataSourceContainer.gameplaySessionDataSource) private var dataSource
}
