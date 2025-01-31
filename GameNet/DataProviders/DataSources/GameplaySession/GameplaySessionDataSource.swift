//
//  GameplaySessionDataSource.swift
//  GameNet
//
//  Created by Alliston Aleixo on 17/02/23.
//

import Foundation
import GameNet_Network

// MARK: - GameplaySessionDataSourceProtocol

protocol GameplaySessionDataSourceProtocol {
    func fetchGameplaySessionsByYear(year: Int, month: Int?) async -> GameplaySessions?
    func save(gameplaySession: GameplaySession) async -> GameplaySession?
}

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
}
