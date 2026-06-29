//
//  GameplaySessionDataSource.swift
//  GameNet
//
//  Created by Alliston Aleixo on 17/02/23.
//

import Foundation

// MARK: - GameplaySessionDataSourceProtocol

protocol GameplaySessionDataSourceProtocol {
    func fetchGameplaySessionsByYear(year: Int, month: Int?) async -> GameplaySessions?
    func save(gameplaySession: GameplaySession) async -> GameplaySession?
    func finishGame(userGameId: String) async -> Bool
    func dropGameplay(userGameId: String) async -> Bool
}

// MARK: - EmptyDataResponse

/// Resposta usada quando só precisamos do `ok` do `APIResult`, ignorando o conteúdo de `data`.
private struct EmptyDataResponse: Codable {}

// MARK: - GameplaySessionDataSource

class GameplaySessionDataSource: GameplaySessionDataSourceProtocol {
    func fetchGameplaySessionsByYear(year: Int, month: Int? = nil) async -> GameplaySessions? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<GameplaySessionsResponse>.self,
                endpoint: .gameplaysByYear(year: year, month: month)
            ) {
            if apiResult.ok {
                return apiResult.data.toGameplaySessions()
            }
        }

        return nil
    }
    
    func save(gameplaySession: GameplaySession) async -> GameplaySession? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<GameplaySessionResponse>.self,
                endpoint: .saveGameplaySession(data: gameplaySession.toRequest())
            ) {
            if apiResult.ok {
                return apiResult.data.toGameplaySession()
            }
        }

        return nil
    }

    func finishGame(userGameId: String) async -> Bool {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<EmptyDataResponse>.self,
                endpoint: .finishGame(userGameId: userGameId)
            ) {
            return apiResult.ok
        }

        return false
    }

    func dropGameplay(userGameId: String) async -> Bool {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<EmptyDataResponse>.self,
                endpoint: .dropGameplay(userGameId: userGameId)
            ) {
            return apiResult.ok
        }

        return false
    }
}
