//
//  MockGameRepository.swift
//  GameNet
//
//  Created by Alliston Aleixo on 20/10/22.
//

import Foundation

struct MockGameRepository: GameRepositoryProtocol {

    // MARK: Internal

    static var lastSavedGame: Game?
    static var lastSavedUserGame: UserGame?

    static func reset() {
        games = Defaults.games
        pagedGames = Defaults.pagedGames
        gameDetail = Defaults.gameDetail
        lastSavedGame = nil
        lastSavedUserGame = nil
    }

    static var previewGameDetail: GameDetail { gameDetail }
    static var previewGameplaySessions: GameplaySessions { gameplaySessions }

    func fetchData(search: String?, page: Int?, pageSize: Int?, platformId: String?) async -> PagedList<Game>? {
        let allGames = MockGameRepository.games
        var filtered = allGames

        if let platformId, !platformId.isEmpty {
            filtered = filtered.filter { $0.platformId == platformId }
        }

        if let search, !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let needle = search.lowercased()
            filtered = filtered.filter { $0.name.lowercased().contains(needle) }
        }

        return PagedList<Game>(
            count: filtered.count,
            totalCount: filtered.count,
            page: page ?? 0,
            pageSize: pageSize ?? filtered.count,
            totalPages: 1,
            search: search,
            result: filtered
        )
    }

    func fetchData(id: String) async -> GameDetail? {
        return MockGameRepository.gameDetail
    }

    func fetchGameplaySessions(id: String) async -> GameplaySessions? {
        return MockGameRepository.gameplaySessions
    }
    
    func save(data: Game, userGameData: UserGame) async -> Bool {
        MockGameRepository.lastSavedGame = data
        MockGameRepository.lastSavedUserGame = userGameData
        return true
    }

    func beginGameplay(userGameId: String, start: Date) async -> GameDetail? {
        var detail = MockGameRepository.gameDetail
        var gameplays = detail.gameplays ?? []
        gameplays.append(Gameplay(start: start, finish: nil))
        detail = GameDetail(
            id: detail.id,
            name: detail.name,
            cover: detail.cover,
            platform: detail.platform,
            value: detail.value,
            boughtDate: detail.boughtDate,
            gameplays: gameplays
        )
        MockGameRepository.gameDetail = detail
        return detail
    }

    func finishGameplay(userGameId: String, finish: Date) async -> GameDetail? {
        var detail = MockGameRepository.gameDetail
        guard var gameplays = detail.gameplays,
              let activeIndex = gameplays.lastIndex(where: { $0.finish == nil }) else {
            return nil
        }

        let active = gameplays[activeIndex]
        gameplays[activeIndex] = Gameplay(start: active.start, finish: finish)
        detail = GameDetail(
            id: detail.id,
            name: detail.name,
            cover: detail.cover,
            platform: detail.platform,
            value: detail.value,
            boughtDate: detail.boughtDate,
            gameplays: gameplays
        )
        MockGameRepository.gameDetail = detail
        return detail
    }

    func dropGameplay(userGameId: String) async -> GameDetail? {
        var detail = MockGameRepository.gameDetail
        guard var gameplays = detail.gameplays,
              let activeIndex = gameplays.lastIndex(where: { $0.finish == nil }) else {
            return nil
        }

        gameplays.remove(at: activeIndex)
        detail = GameDetail(
            id: detail.id,
            name: detail.name,
            cover: detail.cover,
            platform: detail.platform,
            value: detail.value,
            boughtDate: detail.boughtDate,
            gameplays: gameplays
        )
        MockGameRepository.gameDetail = detail
        return detail
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
                    start: Calendar.current.date(byAdding: .hour, value: -77, to: Date())!,
                    finish: Calendar.current.date(byAdding: .hour, value: -71, to: Date())!,
                    gameName: "The Legend of Zelda: Tears of the Kingdom",
                    gameCover: "https://images.nintendolife.com/da314926e706f/switch-tloz-totk-boxart-011.large.jpg",
                    platformName: "Nintendo Switch",
                    totalGameplayTime: "01:20"
                ),
                GameplaySession(
                    id: "2",
                    userGameId: "1",
                    start: Calendar.current.date(byAdding: .hour, value: -29, to: Date())!,
                    finish: Calendar.current.date(byAdding: .hour, value: -28, to: Date())!,
                    gameName: "The Legend of Zelda: Tears of the Kingdom",
                    gameCover: "https://images.nintendolife.com/da314926e706f/switch-tloz-totk-boxart-011.large.jpg",
                    platformName: "Nintendo Switch",
                    totalGameplayTime: "01:20"
                ),
                GameplaySession(
                    id: "3",
                    userGameId: "1",
                    start: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!,
                    finish: Calendar.current.date(byAdding: .hour, value: -4, to: Date())!,
                    gameName: "The Legend of Zelda: Tears of the Kingdom",
                    gameCover: "https://images.nintendolife.com/da314926e706f/switch-tloz-totk-boxart-011.large.jpg",
                    platformName: "Nintendo Switch",
                    totalGameplayTime: "01:20"
                ),
                GameplaySession(
                    id: "4",
                    userGameId: "1",
                    start: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!,
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
    fileprivate static var gameDetail = Defaults.gameDetail
    private static var gameplaySessions = Defaults.gameplaySessions
}
