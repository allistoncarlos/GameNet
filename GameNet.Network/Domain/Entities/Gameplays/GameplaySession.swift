//
//  GameplaySession.swift
//
//  Created by Alliston Aleixo on 20/05/22.
//

import Foundation
import SwiftData

@Model
public class GameplaySession: Identifiable, Equatable, Hashable, Codable {

    // MARK: Lifecycle

    public init(
        id: String?,
        userGameId: String,
        start: Date,
        finish: Date?,
        gameName: String,
        gameCover: String,
        platformName: String,
        totalGameplayTime: String
    ) {
        self.id = id
        self.userGameId = userGameId
        self.start = start
        self.finish = finish
        self.gameName = gameName
        self.gameCover = gameCover
        self.platformName = platformName
        self.totalGameplayTime = totalGameplayTime
    }

    // MARK: Public

    public var id: String?
    public var userGameId: String
    public var start: Date
    public var finish: Date?
    public var gameName: String
    public var gameCover: String
    public var platformName: String
    public var totalGameplayTime: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userGameId
        case start
        case finish
        case gameName
        case gameCover
        case platformName
        case totalGameplayTime
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String?.self, forKey: .id)
        userGameId = try container.decode(String.self, forKey: .userGameId)
        start = try container.decode(Date.self, forKey: .start)
        finish = try container.decode(Date?.self, forKey: .finish)
        gameName = try container.decode(String.self, forKey: .gameName)
        gameCover = try container.decode(String.self, forKey: .gameCover)
        platformName = try container.decode(String.self, forKey: .platformName)
        totalGameplayTime = try container.decode(String.self, forKey: .totalGameplayTime)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userGameId, forKey: .userGameId)
        try container.encode(start, forKey: .start)
        try container.encode(finish, forKey: .finish)
        try container.encode(gameName, forKey: .gameName)
        try container.encode(gameCover, forKey: .gameCover)
        try container.encode(platformName, forKey: .platformName)
        try container.encode(totalGameplayTime, forKey: .totalGameplayTime)
    }
    
    public func toRequest() -> GameplaySessionRequest {
        return GameplaySessionRequest(
            userGameId: userGameId,
            start: start,
            finish: finish,
            id: id
        )
    }
}
