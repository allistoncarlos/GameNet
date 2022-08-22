//
//  MockDashboardRepository.swift
//  GameNet
//
//  Created by Alliston Aleixo on 22/08/22.
//

import Foundation
import GameNet_Network

struct MockDashboardRepository: DashboardRepositoryProtocol {
    func fetchData() async -> Dashboard? {
        let boughtByYear: [BoughtGamesByYearTotal]? = [
            BoughtGamesByYearTotal(year: 2022, total: 500, quantity: 10),
            BoughtGamesByYearTotal(year: 2021, total: 100, quantity: 3),
            BoughtGamesByYearTotal(year: 2020, total: 250, quantity: 5),
        ]

        let finishedByYear: [FinishedGameByYearTotal]? = [
            FinishedGameByYearTotal(year: 2022, total: 5),
            FinishedGameByYearTotal(year: 2021, total: 4),
            FinishedGameByYearTotal(year: 2020, total: 3),
        ]

        let latestGameplaySession = LatestGameplaySession(id: "1", userGameId: "123", start: Date.now, finish: Date.now)

        let playingGames: [PlayingGame]? = [
            PlayingGame(id: "1", name: "The Legend of Zelda: Breath of the Wild", platform: "Nintendo Switch", latestGameplaySession: latestGameplaySession),
            PlayingGame(id: "2", name: "Horizon: Forbidden West", platform: "PlayStation 5", latestGameplaySession: latestGameplaySession),
        ]

        let physicalDigital = PhysicalDigital(physical: 200, digital: 1)

        let gamesByPlatform = PlatformGames(total: 12, platforms: [
            PlatformGame(id: "1", name: "Nintendo Switch", platformGamesTotal: 2),
            PlatformGame(id: "2", name: "PlayStation 5", platformGamesTotal: 2),
        ])

        return Dashboard(boughtByYear: boughtByYear, finishedByYear: finishedByYear, playingGames: playingGames, physicalDigital: physicalDigital, gamesByPlatform: gamesByPlatform, totalPrice: 4500, totalGames: 500)
    }
}
