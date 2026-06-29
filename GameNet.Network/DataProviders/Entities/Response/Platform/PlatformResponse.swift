//
//  PlatformResponse.swift
//
//  Created by Alliston Aleixo on 18/05/22.
//

import Foundation

public struct PlatformResponse: Identifiable, Codable {
    public var id: String?
    public var name: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    public func toPlatform() -> Platform {
        return Platform(id: self.id, name: self.name)
    }
}
