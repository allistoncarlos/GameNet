//
//  MockGameRepository.swift
//  GameNet
//
//  Created by Alliston Aleixo on 20/10/22.
//

import Foundation
import GameNet_Network

struct MockGameRepository: GameRepositoryProtocol {

    // MARK: Internal

    static func reset() {
        games = Defaults.games
        pagedGames = Defaults.pagedGames
    }

    func fetchData(search: String?, page: Int?, pageSize: Int?) async -> PagedList<Game>? {
        return MockGameRepository.pagedGames
    }

    // MARK: Private

    private enum Defaults {
        static let games = [
            Game(
                id: "1",
                name: "The Legend of Zelda: Tears of the Kingdom",
                cover: nil,
                coverURL: "https://images.nintendolife.com/da314926e706f/switch-tloz-totk-boxart-011.large.jpg",
                platformId: "1",
                platform: "Nintendo Switch"
            ),
            Game(
                id: "2",
                name: "The Legend of Zelda: Breath of the Wild",
                cover: nil,
                coverURL: "https://assets.reedpopcdn.com/148430785862.jpg/BROK/resize/1920x1920%3E/format/jpg/quality/80/148430785862.jpg",
                platformId: "1",
                platform: "Nintendo Switch"
            ),
            Game(
                id: "3",
                name: "Horizon: Forbidden West",
                cover: nil,
                coverURL: "https://external-preview.redd.it/OzsaIK6E_JF0g4e75_6cumr1Om5UnY3fN96VXpQBDgE.png?auto=webp&s=25fe8691723f22aeee5696e6d129c9f8d36ba7c4",
                platformId: "2",
                platform: "PlayStation 5"
            ),
            Game(
                id: "4",
                name: "Pokémon Violet",
                cover: nil,
                coverURL: "https://pbs.twimg.com/media/FULqfV8XoAA7Beg?format=jpg&name=large",
                platformId: "1",
                platform: "Nintendo Switch"
            )
        ]

        static let pagedGames = PagedList<Game>.init(
            count: 4,
            totalCount: 4,
            page: 0,
            pageSize: 4,
            totalPages: 1,
            search: "",
            result: games
        )
    }

    private static var games = Defaults.games
    private static var pagedGames = Defaults.pagedGames
}
