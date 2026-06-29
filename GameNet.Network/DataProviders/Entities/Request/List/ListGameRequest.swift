//
//  ListGameRequest.swift
//
//  Created by Alliston Aleixo on 02/10/23.
//

import Foundation

public struct ListGameRequest: Identifiable, Encodable {
    public var id: String?
    public var name: String?
    public var games: [ListItemRequest] = []
    

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case games
    }
}
