//
//  LatestGameplaySessionResponse.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation

public struct LatestGameplaySessionResponse: Identifiable, Codable {
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
    
    public func toLatestGameplaySession() -> LatestGameplaySession {
        return LatestGameplaySession(id: self.id,
                                     userGameId: self.userGameId,
                                     start: self.start,
                                     finish: self.finish)
    }
}
