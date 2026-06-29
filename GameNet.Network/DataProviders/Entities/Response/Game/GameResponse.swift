//
//  GameResponse.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation

public struct GameResponse: Identifiable, Codable {
    public var id: String?
    public var name: String
    public var cover: String
    public var platformId: String
    public var platform: String

    enum CodingKeys: String, CodingKey {
        case id
        case name = "gameName"
        case cover = "gameCoverURL"
        case platformId
        case platform = "platformName"
    }
    
    public func toGame() -> Game {
        return Game(id: self.id,
                    name: self.name,
                    cover: nil,
                    coverURL: self.cover,
                    platformId: self.platformId,
                    platform: self.platform)
    }
}
