//
//  ServerDrivenResponse.swift
//  GameNet.Network
//
//  Created by Alliston Aleixo on 23/11/24.
//

import Foundation

public struct ServerDrivenResponse: Identifiable, Codable {
    public var id: String?
    public var slug: String
    public var json: String

    enum CodingKeys: String, CodingKey {
        case id
        case slug
        case json
    }
    
    public func toServerDriven() -> ServerDriven {
        return ServerDriven(id: self.id, slug: self.slug, json: self.json)
    }
}
