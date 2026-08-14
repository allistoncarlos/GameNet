//
//  TheGamesDBRepository.swift
//  GameNet
//

import Factory
import Foundation

protocol TheGamesDBRepositoryProtocol {
    var hasAPIKey: Bool { get }
    func searchGames(name: String, coverPlatformName: String?) async -> [TheGamesDBGame]
    func boxartURL(gameId: Int) async -> URL?
    func downloadImage(from url: URL) async -> Data?
}

struct TheGamesDBRepository: TheGamesDBRepositoryProtocol {
    @Injected(\.theGamesDBDataSource) private var dataSource

    var hasAPIKey: Bool {
        dataSource.hasAPIKey
    }

    func searchGames(name: String, coverPlatformName: String?) async -> [TheGamesDBGame] {
        let platforms = await dataSource.platforms()
        let namesById = Dictionary(uniqueKeysWithValues: platforms.map { ($0.id, $0.name) })
        let parsed = PlatformCoverResolver.catalogSearch(from: name, platforms: platforms)
        let platformHint = parsed.platformHint ?? coverPlatformName

        var platformId: Int?
        if let platformHint {
            platformId = PlatformCoverResolver.matchTheGamesDBPlatform(
                coverSearchName: platformHint,
                platforms: platforms
            )
        }

        return await dataSource.searchGames(name: parsed.gameName, platformId: platformId).map { game in
            var enriched = game
            if let id = game.platformId {
                enriched.platformName = namesById[id]
            }
            return enriched
        }
    }

    func boxartURL(gameId: Int) async -> URL? {
        await dataSource.boxartURL(gameId: gameId)
    }

    func downloadImage(from url: URL) async -> Data? {
        await dataSource.downloadImage(from: url)
    }
}
