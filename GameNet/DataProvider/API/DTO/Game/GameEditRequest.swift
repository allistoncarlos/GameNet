//
//  GameEditRequest.swift
//
//  Created by Alliston Aleixo on 18/05/22.
//

import Foundation

public struct GameEditRequest: Identifiable, Codable {
    public var id: String?
    public var name: String
    public var cover: Data
    public var platformId: String

    enum CodingKeys: String, CodingKey {
        case id
        case name = "gameName"
        case cover = "gameCoverURL"
        case platformId
    }
    
    public init(id: String?,
                name: String,
                cover: Data,
                platformId: String
    ) {
        self.id = id
        self.name = name
        self.cover = cover
        self.platformId = platformId
    }
}
