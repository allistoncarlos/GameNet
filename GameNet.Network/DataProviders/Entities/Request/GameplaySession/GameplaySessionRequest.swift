//
//  GameplaySessionRequest.swift
//  GameNet.Network
//
//  Created by Alliston Aleixo on 14/11/24.
//

import Foundation

public struct GameplaySessionRequest: Identifiable, Codable {
    public var id: String?
    public var userGameId: String
    public var start: Date
    public var finish: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userGameId
        case start
        case finish
    }
    
    public init(
        userGameId: String,
        start: Date,
        finish: Date? = nil,
        id: String? = nil
    ) {
        self.id = id
        self.userGameId = userGameId
        self.start = start
        self.finish = finish
    }
}
