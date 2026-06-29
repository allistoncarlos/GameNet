//
//  ListItemResponse.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation

public struct ListItemResponse: Identifiable, Codable {
    public var id: String?
    public var name: String
    public var platform: String
    public var year: Int?
    public var userGameId: String?
    public var boughtDate: Date?
    public var value: Decimal?
    public var start: Date?
    public var finish: Date?
    public var cover: String?
    public var order: Int?
    public var comment: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name = "gameName"
        case platform = "platformName"
        case year
        case userGameId
        case boughtDate
        case value
        case start
        case finish
        case cover
        case order
        case comment
    }

    public func toListItem() -> ListItem {
        return ListItem(id: self.id,
                        name: self.name,
                        platform: self.platform,
                        userGameId: self.userGameId,
                        year: self.year,
                        boughtDate: self.boughtDate,
                        value: self.value,
                        start: self.start,
                        finish: self.finish,
                        cover: self.cover,
                        order: self.order,
                        comment: self.comment)
    }
}

public struct ListGameResponse: Identifiable, Codable {
    public var id: String?
    public var name: String
    public var creationDate: Date?
    public var games: [ListItemResponse]?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case creationDate
        case games
    }
    
    public func toListGame() -> ListGame {
        return ListGame(id: self.id,
                        name: self.name,
                        games: self.games?.compactMap { $0.toListItem() })
    }
}
