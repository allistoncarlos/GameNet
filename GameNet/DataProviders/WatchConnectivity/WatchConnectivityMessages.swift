//
//  WatchConnectivityMessages.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/05/26.
//

import Foundation

// MARK: - WatchMessageKey

enum WatchMessageKey {
    static let askForCredentials = "ASK_FOR_CREDENTIALS"
    static let authInfo = "AUTH_INFO"
    static let notLogged = "NOT_LOGGED"
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

// MARK: - WatchPlayingGame

struct WatchPlayingGame: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let coverURL: String
    let latestSessionStartISO: String?
    let isSessionActive: Bool

    var isStarted: Bool { isSessionActive }
}

// MARK: - WatchPlayingGamesPayload

struct WatchPlayingGamesPayload: Codable {
    let games: [WatchPlayingGame]
}

// MARK: - WatchToggleGameplayRequest

struct WatchToggleGameplayRequest: Codable {
    let userGameId: String
    let isCurrentlyStarted: Bool
    let latestSessionStartISO: String?
}

// MARK: - WatchGameplayUpdatedPayload

struct WatchGameplayUpdatedPayload: Codable {
    let userGameId: String
    let latestSessionStartISO: String?
    let isSessionActive: Bool
}

// MARK: - WatchConnectivityPayloadCodec

enum WatchConnectivityPayloadCodec {
    static func encode<T: Encodable>(_ value: T) -> Data? {
        try? JSONEncoder().encode(value)
    }

    static func decode<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        try? JSONDecoder().decode(type, from: data)
    }

    static func reply<T: Encodable>(_ key: String, value: T) -> [String: Any] {
        guard let data = encode(value) else {
            return [WatchMessageKey.error: "encode_failed"]
        }
        return [key: data]
    }
}
