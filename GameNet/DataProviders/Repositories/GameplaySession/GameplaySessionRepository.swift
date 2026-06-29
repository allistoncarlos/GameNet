//
//  GameplaySessionRepository.swift
//  GameNet
//
//  Created by Alliston Aleixo on 17/02/23.
//

import Factory
import Foundation

// MARK: - GameplaySessionRepositoryProtocol

protocol GameplaySessionRepositoryProtocol {
    func fetchGameplaySessionsByYear(year: Int, month: Int?) async -> GameplaySessions?
    func save(
        userGameId: String,
        start: Date,
        finish: Date?,
        id: String?
    ) async -> GameplaySession?
    func finishGame(userGameId: String) async -> Bool
    func dropGameplay(userGameId: String) async -> Bool
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

    func finishGame(userGameId: String) async -> Bool {
        return await dataSource.finishGame(userGameId: userGameId)
    }

    func dropGameplay(userGameId: String) async -> Bool {
        return await dataSource.dropGameplay(userGameId: userGameId)
    }

    // MARK: Private

    @Injected(DataSourceContainer.gameplaySessionDataSource) private var dataSource
}
