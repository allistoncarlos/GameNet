//
//  GameDataSource.swift
//  GameNet
//
//  Created by Alliston Aleixo on 20/10/22.
//

import Factory
import Foundation

// MARK: - GameDataSourceProtocol

protocol GameDataSourceProtocol {
    func fetchData(search: String?, page: Int?, pageSize: Int?, platformId: String?) async -> PagedList<Game>?
    func fetchData(id: String) async -> GameDetail?
    func fetchGameplaySessions(id: String) async -> GameplaySessions?
    func save(data: Game, userGameData: UserGame) async -> Bool
    func beginGameplay(userGameId: String, start: Date) async -> GameDetail?
    func finishGameplay(userGameId: String, finish: Date) async -> GameDetail?
    func dropGameplay(userGameId: String) async -> GameDetail?
}

// MARK: - GameDataSource

class GameDataSource: GameDataSourceProtocol {

    // MARK: Internal

    @Injected(\.tokenDataSource) private var tokenDataSource

    func fetchData(search: String?, page: Int?, pageSize: Int?, platformId: String?) async -> PagedList<Game>? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<PagedResult<GameResponseDTO>>.self,
                endpoint: .games(search: search, page: page, pageSize: pageSize, platformId: platformId)
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
                responseType: APIResult<GameDetailResponseDTO>.self,
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
                responseType: APIResult<GameplaySessionsResponseDTO>.self,
                endpoint: .gameplays(id: id)
            ) {
            if apiResult.ok {
                return apiResult.data.toGameplaySessions()
            }
        }

        return nil
    }

    func save(data: Game, userGameData: UserGame) async -> Bool {
        if let apiResult = await NetworkManager.shared
            .performUploadGame(data: data.toRequest()) {
            if apiResult.ok {
                if let userId = tokenDataSource.id,
                   let gameId = apiResult.data.id {
                    let resultUserGameRequest = UserGameEditRequest(
                        id: nil,
                        gameId: gameId,
                        userId: userId,
                        price: userGameData.price,
                        boughtDate: userGameData.boughtDate,
                        have: userGameData.have,
                        want: userGameData.want,
                        digital: userGameData.digital,
                        original: userGameData.original
                    )

                    return await saveUserGame(data: resultUserGameRequest)
                }
            } else {
                return false
            }
        }

        return false
    }

    func beginGameplay(userGameId: String, start: Date) async -> GameDetail? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<GameDetailResponseDTO>.self,
                endpoint: .beginUserGameGameplay(userGameId: userGameId, start: start)
            ) {
            if apiResult.ok {
                return apiResult.data.toGameDetail()
            }
        }

        return nil
    }

    func finishGameplay(userGameId: String, finish: Date) async -> GameDetail? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<GameDetailResponseDTO>.self,
                endpoint: .finishUserGameGameplay(userGameId: userGameId, finish: finish)
            ) {
            if apiResult.ok {
                return apiResult.data.toGameDetail()
            }
        }

        return nil
    }

    func dropGameplay(userGameId: String) async -> GameDetail? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<GameDetailResponseDTO>.self,
                endpoint: .dropUserGameGameplay(userGameId: userGameId)
            ) {
            if apiResult.ok {
                return apiResult.data.toGameDetail()
            }
        }

        return nil
    }

    // MARK: Private

    private func saveUserGame(data: UserGameEditRequest) async -> Bool {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<UserGameEditResponseDTO>.self,
                endpoint: .saveUserGame(data: data)
            ) {
            return apiResult.ok
        }

        return false
    }
}
