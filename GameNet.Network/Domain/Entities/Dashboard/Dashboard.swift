//
//  Dashboard.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation
import SwiftData

@Model
public class Dashboard: Equatable, Hashable {

    // MARK: Lifecycle

    public init(
        boughtByYear: [BoughtGamesByYearTotal]?,
        finishedByYear: [FinishedGameByYearTotal]?,
        playingGames: [PlayingGame]?,
        physicalDigital: PhysicalDigital?,
        gamesByPlatform: PlatformGames?,
        totalPrice: Double?,
        totalGames: Int?
    ) {
        self.boughtByYear = boughtByYear
        self.finishedByYear = finishedByYear
        self.playingGames = playingGames
        self.physicalDigital = physicalDigital
        self.gamesByPlatform = gamesByPlatform
        self.totalPrice = totalPrice
        self.totalGames = totalGames
    }

    // MARK: Public

    public var boughtByYear: [BoughtGamesByYearTotal]?
    public var finishedByYear: [FinishedGameByYearTotal]?
    public var playingGames: [PlayingGame]?
    public var physicalDigital: PhysicalDigital?
    public var gamesByPlatform: PlatformGames?
    public var totalPrice: Double?
    public var totalGames: Int?

}
