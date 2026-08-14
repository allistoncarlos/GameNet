//
//  CreateGameService.swift
//  GameNet
//

import Factory
import Foundation

enum CreateGameResult: Equatable {
    case created(gameName: String, platformName: String)
    case needsGameChoice([TheGamesDBGame])
    case notLoggedIn
    case missingAPIKey
    case platformNotFound
    case gameNotFound
    case coverDownloadFailed
    case saveFailed
}

struct CreateGameService {
    let platformRepository: PlatformRepositoryProtocol
    let gameRepository: GameRepositoryProtocol
    let catalogRepository: TheGamesDBRepositoryProtocol
    let tokenDataSource: TokenDataSourceProtocol

    static func make() -> CreateGameService {
        CreateGameService(
            platformRepository: Container.shared.platformRepository(),
            gameRepository: Container.shared.gameRepository(),
            catalogRepository: Container.shared.theGamesDBRepository(),
            tokenDataSource: Container.shared.tokenDataSource()
        )
    }

    func platforms() async -> [Platform] {
        await platformRepository.fetchData(cache: true) ?? []
    }

    func matchingPlatforms(query: String) async -> [Platform] {
        PlatformCoverResolver.candidates(
            matching: query,
            in: await platforms()
        )
    }

    func searchCatalog(name: String, platform: Platform) async -> [TheGamesDBGame] {
        let parsed = PlatformCoverResolver.parse(platform.name)
        return await catalogRepository.searchGames(
            name: name,
            coverPlatformName: parsed.coverSearchName
        )
    }

    func create(name: String, platform: Platform, catalogGame: TheGamesDBGame? = nil) async -> CreateGameResult {
        guard tokenDataSource.hasValidToken() else {
            return .notLoggedIn
        }

        guard catalogRepository.hasAPIKey else {
            return .missingAPIKey
        }

        let selectedGame: TheGamesDBGame
        if let catalogGame {
            selectedGame = catalogGame
        } else {
            let results = await searchCatalog(name: name, platform: platform)
            if results.isEmpty {
                return .gameNotFound
            }
            if results.count > 1 {
                return .needsGameChoice(results)
            }
            selectedGame = results[0]
        }

        guard let boxartURL = await catalogRepository.boxartURL(gameId: selectedGame.id),
              let cover = await catalogRepository.downloadImage(from: boxartURL),
              let platformId = platform.id else {
            return .coverDownloadFailed
        }

        let game = Game(
            id: nil,
            name: selectedGame.name,
            cover: cover,
            coverURL: nil,
            platformId: platformId,
            platform: platform.name
        )

        let userGame = UserGame(
            id: nil,
            gameId: "",
            userId: "",
            price: 0,
            boughtDate: Date(),
            have: false,
            want: false,
            digital: true,
            original: false
        )

        let saved = await gameRepository.save(data: game, userGameData: userGame)
        guard saved else {
            return .saveFailed
        }

        return .created(gameName: selectedGame.name, platformName: platform.name)
    }
}
