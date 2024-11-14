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
    func save(
        userGameId: String,
        start: Date,
        finish: Date?,
        id: String?
    ) async -> GameplaySession?
}

// MARK: - GameplaySessionRepository

struct GameplaySessionRepository: GameplaySessionRepositoryProtocol {

    // MARK: Internal

    func fetchGameplaySessionsByYear(year: Int, month: Int? = nil) async -> GameplaySessions? {
        return await dataSource.fetchGameplaySessionsByYear(year: year, month: month)
    }

    func save(
        userGameId: String,
        start: Date,
        finish: Date? = nil,
        id: String? = nil
    ) async -> GameplaySession? {
        let gameplaySession = GameplaySession(
            id: id,
            userGameId: userGameId,
            start: start,
            finish: finish,
            gameName: "",
            gameCover: "",
            platformName: "",
            totalGameplayTime: ""
        )
    
        return await dataSource.save(gameplaySession: gameplaySession)
    }

    // MARK: Private

    @Injected(DataSourceContainer.gameplaySessionDataSource) private var dataSource
}
