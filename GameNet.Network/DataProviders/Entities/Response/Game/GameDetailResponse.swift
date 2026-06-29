//
//  GameDetailResponse.swift
//
//  Created by Alliston Aleixo on 20/05/22.
//

import Foundation

public struct GameDetailResponse: Identifiable, Codable {

    // MARK: Public

    public var id: String?
    public var name: String
    public var cover: String
    public var platform: String
    public var value: Decimal
    public var boughtDate: Date?
    public var gameplays: [GameplayResponse]?

    public func toGameDetail() -> GameDetail {
        return GameDetail(
            id: id,
            name: name,
            cover: cover,
            platform: platform,
            value: value,
            boughtDate: boughtDate,
            gameplays: gameplays?.compactMap { $0.toGameplay() }
        )
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case id
        case name = "gameName"
        case cover = "gameCoverURL"
        case platform = "platformName"
        case value
        case boughtDate
        case gameplays
    }
}
