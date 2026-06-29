//
//  PlatformGamesResponse.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation

public struct PlatformGameResponse: Identifiable, Codable {
    public var id: String?
    public var name: String
    public var platformGamesTotal: Int

    enum CodingKeys: String, CodingKey {
        case id = "platformId"
        case name = "platformName"
        case platformGamesTotal
    }
    
    public func toPlatformGame() -> PlatformGame {
        return PlatformGame(id: self.id,
                            name: self.name,
                            platformGamesTotal: self.platformGamesTotal)
    }
}

public struct PlatformGamesResponse: Codable {
    public var total: Int
    public var platforms: [PlatformGameResponse]

    enum CodingKeys: String, CodingKey {
        case total
        case platforms
    }
    
    public func toPlatformGames() -> PlatformGames {
        return PlatformGames(total: self.total,
                             platforms: self.platforms.compactMap { $0.toPlatformGame() })
    }
}
