//
//  GameRepository.swift
//  GameNet
//
//  Created by Alliston Aleixo on 20/10/22.
//

import Factory
import Foundation

// MARK: - GameRepositoryProtocol

protocol GameRepositoryProtocol {
    func fetchData(search: String?, page: Int?, pageSize: Int?, platformId: String?) async -> PagedList<Game>?
    func fetchData(id: String) async -> GameDetail?
    func fetchGameplaySessions(id: String) async -> GameplaySessions?
    func save(data: Game, userGameData: UserGame) async -> Bool
    func beginGameplay(userGameId: String, start: Date) async -> GameDetail?
    func finishGameplay(userGameId: String, finish: Date) async -> GameDetail?
    func dropGameplay(userGameId: String) async -> GameDetail?
}

extension GameRepositoryProtocol {
    func fetchData(search: String?, page: Int?, pageSize: Int?) async -> PagedList<Game>? {
        await fetchData(search: search, page: page, pageSize: pageSize, platformId: nil)
    }
}

// MARK: - GameRepository

struct GameRepository: GameRepositoryProtocol {

    // MARK: Internal

    func fetchData(search: String?, page: Int?, pageSize: Int?, platformId: String?) async -> PagedList<Game>? {
        return await dataSource.fetchData(search: search, page: page, pageSize: pageSize, platformId: platformId)
    }

    func fetchData(id: String) async -> GameDetail? {
        return await dataSource.fetchData(id: id)
    }

    func fetchGameplaySessions(id: String) async -> GameplaySessions? {
        return await dataSource.fetchGameplaySessions(id: id)
    }

    func save(data: Game, userGameData: UserGame) async -> Bool {
        return await dataSource.save(data: data, userGameData: userGameData)
    }

    func beginGameplay(userGameId: String, start: Date) async -> GameDetail? {
        return await dataSource.beginGameplay(userGameId: userGameId, start: start)
    }

    func finishGameplay(userGameId: String, finish: Date) async -> GameDetail? {
        return await dataSource.finishGameplay(userGameId: userGameId, finish: finish)
    }

    func dropGameplay(userGameId: String) async -> GameDetail? {
        return await dataSource.dropGameplay(userGameId: userGameId)
    }

    // MARK: Private

    @Injected(\.gameDataSource) private var dataSource
}
