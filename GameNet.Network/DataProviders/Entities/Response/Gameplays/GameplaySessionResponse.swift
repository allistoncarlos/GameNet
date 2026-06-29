//
//  GameplaySessionResponse.swift
//
//  Created by Alliston Aleixo on 20/05/22.
//

import Foundation

public struct GameplaySessionResponse: Identifiable, Codable {

    // MARK: Public

    public var id: String?
    public var userGameId: String
    public var start: Date
    public var finish: Date?
    public var gameName: String
    public var gameCover: String
    public var platformName: String
    public var totalGameplayTime: String

    public func toGameplaySession() -> GameplaySession {
        return GameplaySession(
            id: id,
            userGameId: userGameId,
            start: start,
            finish: finish,
            gameName: gameName,
            gameCover: gameCover,
            platformName: platformName,
            totalGameplayTime: totalGameplayTime
        )
    }

    // MARK: Internal

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
}
