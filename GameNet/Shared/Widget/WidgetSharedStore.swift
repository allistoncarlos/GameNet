//
//  WidgetSharedStore.swift
//  GameNet
//
//  Ponte de dados entre o app e a Widget Extension, via App Group.
//

import Foundation
import WidgetKit

// MARK: - WidgetSharedPlayingGame

/// Representação enxuta de um jogo "jogando agora", compartilhada com o widget.
public struct WidgetSharedPlayingGame: Codable, Identifiable, Hashable {
    public var id: String
    public var name: String
    public var platform: String
    public var coverURL: String
    public var latestSessionId: String?
    public var latestStart: Date?
    public var latestFinish: Date?

    public init(
        id: String,
        name: String,
        platform: String,
        coverURL: String,
        latestSessionId: String?,
        latestStart: Date?,
        latestFinish: Date?
    ) {
        self.id = id
        self.name = name
        self.platform = platform
        self.coverURL = coverURL
        self.latestSessionId = latestSessionId
        self.latestStart = latestStart
        self.latestFinish = latestFinish
    }

    /// Sessão em andamento = existe início sem término.
    public var isStarted: Bool {
        latestStart != nil && latestFinish == nil
    }

    /// Critério para "último jogado": data de atividade mais recente.
    public var lastActivityDate: Date {
        latestFinish ?? latestStart ?? .distantPast
    }
}

// MARK: - WidgetSharedAuth

public struct WidgetSharedAuth: Codable {
    public var accessToken: String
    public var refreshToken: String
    public var expiresIn: Date?

    public init(accessToken: String, refreshToken: String, expiresIn: Date?) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
    }
}

// MARK: - WidgetSharedStore

public enum WidgetSharedStore {
    public static let appGroupId = "group.com.alliston.GameNetApp"
    public static let widgetKind = "GameNetPlayGameWidget"

    private enum Key {
        static let accessToken = "widget.accessToken"
        static let refreshToken = "widget.refreshToken"
        static let expiresIn = "widget.expiresIn"
        static let apiBaseURL = "widget.apiBaseURL"
        static let playingGames = "widget.playingGames"
        static let isLogged = "widget.isLogged"
    }

    public static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }

    private static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    // MARK: Auth

    public static func saveAuth(
        accessToken: String,
        refreshToken: String,
        expiresIn: Date?
    ) {
        guard let defaults else { return }

        defaults.set(accessToken, forKey: Key.accessToken)
        defaults.set(refreshToken, forKey: Key.refreshToken)
        if let expiresIn {
            defaults.set(expiresIn.timeIntervalSince1970, forKey: Key.expiresIn)
        } else {
            defaults.removeObject(forKey: Key.expiresIn)
        }
        defaults.set(true, forKey: Key.isLogged)
    }

    public static func loadAuth() -> WidgetSharedAuth? {
        guard let defaults,
              let accessToken = defaults.string(forKey: Key.accessToken),
              let refreshToken = defaults.string(forKey: Key.refreshToken) else {
            return nil
        }

        let expiresIn: Date?
        if defaults.object(forKey: Key.expiresIn) != nil {
            expiresIn = Date(timeIntervalSince1970: defaults.double(forKey: Key.expiresIn))
        } else {
            expiresIn = nil
        }

        return WidgetSharedAuth(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: expiresIn
        )
    }

    public static var isLogged: Bool {
        defaults?.bool(forKey: Key.isLogged) ?? false
    }

    public static func clearAuth() {
        guard let defaults else { return }

        defaults.removeObject(forKey: Key.accessToken)
        defaults.removeObject(forKey: Key.refreshToken)
        defaults.removeObject(forKey: Key.expiresIn)
        defaults.removeObject(forKey: Key.playingGames)
        defaults.set(false, forKey: Key.isLogged)
    }

    // MARK: API base URL

    public static func saveAPIBaseURL(_ baseURL: String) {
        defaults?.set(baseURL, forKey: Key.apiBaseURL)
    }

    public static var apiBaseURL: String? {
        defaults?.string(forKey: Key.apiBaseURL)
    }

    // MARK: Playing games cache

    public static func savePlayingGames(_ games: [WidgetSharedPlayingGame]) {
        guard let defaults else { return }

        if let data = try? encoder.encode(games) {
            defaults.set(data, forKey: Key.playingGames)
        }
    }

    public static func loadPlayingGames() -> [WidgetSharedPlayingGame] {
        guard let defaults,
              let data = defaults.data(forKey: Key.playingGames),
              let games = try? decoder.decode([WidgetSharedPlayingGame].self, from: data) else {
            return []
        }

        return games
    }

    // MARK: Reload

    public static func reloadWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
    }
}
