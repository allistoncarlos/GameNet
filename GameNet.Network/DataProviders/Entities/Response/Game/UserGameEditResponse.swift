//
//  UserGameEditResponse.swift
//
//  Created by Alliston Aleixo on 18/05/22.
//

import Foundation

public struct UserGameEditResponse: Identifiable, Codable {
    public var id: String?
    public var userId: String
    public var gameId: String
    public var name: String?
    public var cover: String?
    public var platformId: String?
    public var platform: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case gameId
        case name = "gameName"
        case cover = "gameCoverURL"
        case platformId
        case platform = "platformName"
    }
}
