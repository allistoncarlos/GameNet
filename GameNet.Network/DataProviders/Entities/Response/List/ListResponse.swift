//
//  ListResponse.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation

public struct ListResponse: Identifiable, Codable {
    public var id: String?
    public var name: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    public func toList() -> List {
        return List(id: self.id, name: self.name)
    }
}
