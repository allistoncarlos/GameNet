//
//  GameEditResponse.swift
//
//  Created by Alliston Aleixo on 18/05/22.
//

import Foundation

public struct GameEditResponse: Identifiable, Codable {
    public var id: String?
    var name: String
    var coverURL: String
    var platform: PlatformResponse

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case coverURL
        case platform
    }
}
