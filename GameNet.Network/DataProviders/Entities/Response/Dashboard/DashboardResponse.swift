//
//  DashboardResponse.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation

public struct DashboardResponse: Codable {
    // MARK: Public

    public var boughtByYear: [BoughtGamesByYearTotalResponse]?
    public var finishedByYear: [FinishedGameByYearTotalResponse]?
    public var playingGames: [PlayingGameResponse]?
    public var physicalDigital: PhysicalDigitalResponse?
    public var gamesByPlatform: PlatformGamesResponse?
    public var totalPrice: Double?
    public var totalGames: Int?

    public func toDashboard() -> Dashboard {
        let boughtByYear = self.boughtByYear?.compactMap { $0.toBoughtGamesByYearTotal() }
        let finishedByYear = self.finishedByYear?.compactMap { $0.toFinishedGameByYearTotal() }
        let playingGames = self.playingGames?.compactMap { $0.toPlayingGame() }
        let physicalDigital = self.physicalDigital?.toPhysicalDigital()
        let gamesByPlatform = self.gamesByPlatform?.toPlatformGames()

        return Dashboard(
            boughtByYear: boughtByYear,
            finishedByYear: finishedByYear,
            playingGames: playingGames,
            physicalDigital: physicalDigital,
            gamesByPlatform: gamesByPlatform,
            totalPrice: totalPrice,
            totalGames: totalGames
        )
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case boughtByYear
        case finishedByYear
        case playingGames
        case physicalDigital
        case gamesByPlatform
        case totalPrice
        case totalGames
    }
}
