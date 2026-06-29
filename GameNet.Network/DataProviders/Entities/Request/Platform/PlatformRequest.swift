//
//  PlatformRequest.swift
//
//  Created by Alliston Aleixo on 18/05/22.
//

import Foundation

public struct PlatformRequest: Identifiable, Codable {
    public var id: String?
    public var name: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    public init(id: String?, name: String) {
        self.id = id
        self.name = name
    }
}
