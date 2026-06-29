//
//  ListItemRequest.swift
//
//  Created by Alliston Aleixo on 02/10/23.
//

import Foundation

public struct ListItemRequest: Identifiable, Codable {
    public var id: String?
    public var userId: String
    public var userGameId: String
    public var listId: String
    public var gameName: String
    public var platformName: String
    public var cover: String
    public var order: Int
    public var comment: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case userGameId
        case listId
        case gameName
        case platformName
        case cover
        case order
        case comment
    }
}
