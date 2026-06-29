//
//  PlayingGameResponse.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation

public struct PlayingGameResponse: Identifiable, Codable {
    public var id: String?
    public var name: String
    public var platform: String
    public var coverURL: String
    public var latestGameplaySession: LatestGameplaySessionResponse?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case platform
        case coverURL
        case latestGameplaySession
    }
    
    public func toPlayingGame() -> PlayingGame {
        return PlayingGame(
            id: self.id,
            name: self.name,
            platform: self.platform,
            coverURL: self.coverURL,
            latestGameplaySession: self.latestGameplaySession?.toLatestGameplaySession()
        )
    }
}
