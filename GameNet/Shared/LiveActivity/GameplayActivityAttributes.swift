//
//  GameplayActivityAttributes.swift
//  GameNet
//
//  Atributos compartilhados entre o app e a Widget Extension para Live Activity.
//

import ActivityKit
import Foundation

public struct GameplayActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        /// Sessão em andamento.
        public var isPlaying: Bool
        /// Início da sessão atual (para timer nativo na Live Activity).
        public var sessionStart: Date

        public init(isPlaying: Bool, sessionStart: Date) {
            self.isPlaying = isPlaying
            self.sessionStart = sessionStart
        }
    }

    public var userGameId: String
    public var gameName: String
    public var platform: String
    public var coverURL: String

    public init(
        userGameId: String,
        gameName: String,
        platform: String,
        coverURL: String
    ) {
        self.userGameId = userGameId
        self.gameName = gameName
        self.platform = platform
        self.coverURL = coverURL
    }
}
