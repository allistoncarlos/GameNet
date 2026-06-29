//
//  GameplaySessionsResponse.swift
//
//  Created by Alliston Aleixo on 20/05/22.
//

import Foundation

public struct GameplaySessionsResponse: Identifiable, Codable {
    public var id: String?
    public var sessions: [GameplaySessionResponse?]
    public var totalGameplayTime: String
    public var averageGameplayTime: String

    enum CodingKeys: String, CodingKey {
        case sessions
        case totalGameplayTime
        case averageGameplayTime
    }
    
    public func toGameplaySessions() -> GameplaySessions {
        return GameplaySessions(id: self.id,
                                        sessions: self.sessions.compactMap { $0?.toGameplaySession() },
                                        totalGameplayTime: self.totalGameplayTime,
                                        averageGameplayTime: self.averageGameplayTime
        )
    }
}
