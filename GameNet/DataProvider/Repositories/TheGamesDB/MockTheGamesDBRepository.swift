//
//  MockTheGamesDBRepository.swift
//  GameNet
//

import Foundation

struct MockTheGamesDBRepository: TheGamesDBRepositoryProtocol {
    static var hasAPIKey = true
    static var games: [TheGamesDBGame] = Defaults.games
    static var boxart: URL? = URL(string: "https://cdn.thegamesdb.net/images/original/boxart/front/1-1.jpg")
    static var imageData: Data? = Data([0x89, 0x50, 0x4E, 0x47])

    static func reset() {
        hasAPIKey = true
        games = Defaults.games
        boxart = Defaults.boxart
        imageData = Defaults.imageData
    }

    var hasAPIKey: Bool { MockTheGamesDBRepository.hasAPIKey }

    func searchGames(name: String, coverPlatformName: String?) async -> [TheGamesDBGame] {
        let needle = name.lowercased()
        return MockTheGamesDBRepository.games.filter { $0.name.lowercased().contains(needle) }
    }

    func boxartURL(gameId: Int) async -> URL? {
        MockTheGamesDBRepository.boxart
    }

    func downloadImage(from url: URL) async -> Data? {
        MockTheGamesDBRepository.imageData
    }

    private enum Defaults {
        static let games = [
            TheGamesDBGame(
                id: 10,
                name: "Little Samson",
                platformId: 7,
                platformName: "Nintendo Entertainment System (NES)",
                released: "1992-11-01",
                boxartURL: nil
            )
        ]
        static let boxart = URL(string: "https://cdn.thegamesdb.net/images/original/boxart/front/1-1.jpg")
        static let imageData = Data([0x89, 0x50, 0x4E, 0x47])
    }
}
