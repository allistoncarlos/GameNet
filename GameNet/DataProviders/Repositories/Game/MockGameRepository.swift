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
        gameDetail = Defaults.gameDetail
    }

    func fetchData(search: String?, page: Int?, pageSize: Int?) async -> PagedList<Game>? {
        return MockGameRepository.pagedGames
    }

    func fetchData(id: String) -> GameDetail? {
        return MockGameRepository.gameDetail
    }

    func fetchGameplaySessions(id: String) -> GameplaySessions? {
        return MockGameRepository.gameplaySessions
    }
    
    func save(data: Game, userGameData: UserGame) async -> Bool {
        return true
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

        static let gameDetail = GameDetail(
            id: "1",
            name: "The Legend of Zelda: Tears of the Kingdom",
            cover: "https://images.nintendolife.com/da314926e706f/switch-tloz-totk-boxart-011.large.jpg",
            platform: "Nintendo Switch",
            value: 180,
            boughtDate: Date(),
            gameplays: [
                Gameplay(start: Date(), finish: Date()),
                Gameplay(start: Date(), finish: nil),
            ]
        )

        static let gameplaySessions = GameplaySessions(
            id: "1",
            sessions: [
                GameplaySession(
                    id: "1",
                    userGameId: "1",
                    start: Date(),
                    finish: Date(),
                    gameName: "The Legend of Zelda: Tears of the Kingdom",
                    gameCover: "https://images.nintendolife.com/da314926e706f/switch-tloz-totk-boxart-011.large.jpg",
                    platformName: "Nintendo Switch",
                    totalGameplayTime: "01:20"
                ),
                GameplaySession(
                    id: "2",
                    userGameId: "1",
                    start: Date(),
                    finish: nil,
                    gameName: "The Legend of Zelda: Tears of the Kingdom",
                    gameCover: "https://images.nintendolife.com/da314926e706f/switch-tloz-totk-boxart-011.large.jpg",
                    platformName: "Nintendo Switch",
                    totalGameplayTime: "0:00"
                ),
            ],
            totalGameplayTime: "18:20",
            averageGameplayTime: "01:45"
        )
    }

    private static var games = Defaults.games
    private static var pagedGames = Defaults.pagedGames
    private static var gameDetail = Defaults.gameDetail
    private static var gameplaySessions = Defaults.gameplaySessions
}
