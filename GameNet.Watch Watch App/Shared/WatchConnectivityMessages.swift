//
//  WatchConnectivityMessages.swift
//  GameNet.Watch Watch App
//
//  Created by Alliston Aleixo on 23/05/26.
//

import Foundation

enum WatchMessageKey {
    static let checkAuth = "CHECK_AUTH"
    static let authStatus = "AUTH_STATUS"
    static let fetchPlayingGames = "FETCH_PLAYING_GAMES"
    static let playingGames = "PLAYING_GAMES"
    static let toggleGameplay = "TOGGLE_GAMEPLAY"
    static let gameplayUpdated = "GAMEPLAY_UPDATED"
    static let error = "ERROR"
}

enum WatchAuthStatus: String, Codable {
    case logged = "LOGGED"
    case notLogged = "NOT_LOGGED"
}

struct WatchPlayingGame: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let coverURL: String
    let latestSessionStartISO: String?
    let isSessionActive: Bool

    var isStarted: Bool { isSessionActive }
}

struct WatchPlayingGamesPayload: Codable {
    let games: [WatchPlayingGame]
}

struct WatchToggleGameplayRequest: Codable {
    let userGameId: String
    let isCurrentlyStarted: Bool
    let latestSessionStartISO: String?
    let habitDayISO: String
}

struct WatchGameplayUpdatedPayload: Codable {
    let userGameId: String
    let latestSessionStartISO: String?
    let isSessionActive: Bool
}

enum WatchConnectivityPayloadCodec {
    static func encode<T: Encodable>(_ value: T) -> Data? {
        try? JSONEncoder().encode(value)
    }

    static func decode<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        try? JSONDecoder().decode(type, from: data)
    }
}
