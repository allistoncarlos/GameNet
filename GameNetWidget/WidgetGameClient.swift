//
//  WidgetGameClient.swift
//  GameNetWidget
//
//  Cliente de rede leve (URLSession) usado pelo widget para ler os jogos
//  em andamento e iniciar/parar gameplays, reaproveitando o token do App Group.
//

import Foundation

// MARK: - API models (mínimos)

private struct WidgetAPIResult<T: Decodable>: Decodable {
    let ok: Bool
    let data: T
}

private struct WidgetDashboardResponse: Decodable {
    let playingGames: [WidgetPlayingGameResponse]?
}

private struct WidgetPlayingGameResponse: Decodable {
    let id: String?
    let name: String
    let platform: String
    let coverURL: String
    let latestGameplaySession: WidgetLatestGameplaySessionResponse?

    func toShared() -> WidgetSharedPlayingGame? {
        guard let id else { return nil }

        return WidgetSharedPlayingGame(
            id: id,
            name: name,
            platform: platform,
            coverURL: coverURL,
            latestSessionId: latestGameplaySession?.id,
            latestStart: latestGameplaySession?.start,
            latestFinish: latestGameplaySession?.finish
        )
    }
}

private struct WidgetLatestGameplaySessionResponse: Decodable {
    let id: String?
    let userGameId: String
    let start: Date
    let finish: Date?
}

private struct WidgetGameplaySessionResponse: Decodable {
    let id: String?
    let userGameId: String
    let start: Date
    let finish: Date?
}

private struct WidgetGameplaySessionRequest: Encodable {
    let id: String?
    let userGameId: String
    let start: Date
    let finish: Date?
}

private struct WidgetRefreshTokenRequest: Encodable {
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

private struct WidgetRefreshTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Date

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}

// MARK: - WidgetGameClient

struct WidgetGameClient {
    enum ClientError: Error {
        case notLogged
        case noBaseURL
        case invalidResponse
        case server
    }

    // MARK: Public API

    func fetchPlayingGames() async throws -> [WidgetSharedPlayingGame] {
        let request = try makeRequest(path: "dashboard", method: "GET")
        let data = try await authorizedData(for: request)
        let result = try decoder.decode(WidgetAPIResult<WidgetDashboardResponse>.self, from: data)

        let games = (result.data.playingGames ?? []).compactMap { $0.toShared() }
        WidgetSharedStore.savePlayingGames(games)
        return games
    }

    /// Inicia ou para a gameplay do jogo, espelhando `GameCoverViewModel.save()`.
    func toggleGameplay(for game: WidgetSharedPlayingGame) async throws -> WidgetSharedPlayingGame {
        let now = Date.timeZoneDate()
        let isStarted = game.isStarted
        let start = isStarted ? (game.latestStart ?? now) : now
        let finish: Date? = isStarted ? now : nil

        let body = WidgetGameplaySessionRequest(
            id: nil,
            userGameId: game.id,
            start: start,
            finish: finish
        )

        let path = finish != nil ? "gameplaysession?userGameId=\(game.id)" : "gameplaysession"
        let method = finish != nil ? "PUT" : "POST"

        var request = try makeRequest(path: path, method: method)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)

        let data = try await authorizedData(for: request)
        let result = try decoder.decode(WidgetAPIResult<WidgetGameplaySessionResponse>.self, from: data)

        guard result.ok else { throw ClientError.server }

        var updated = game
        updated.latestSessionId = result.data.id
        updated.latestStart = result.data.start
        updated.latestFinish = result.data.finish
        return updated
    }

    // MARK: Private

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    private func makeRequest(path: String, method: String) throws -> URLRequest {
        guard let baseURL = WidgetSharedStore.apiBaseURL else { throw ClientError.noBaseURL }
        guard let url = URL(string: "\(baseURL)/\(path)") else { throw ClientError.noBaseURL }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 15
        return request
    }

    private func authorizedData(for request: URLRequest) async throws -> Data {
        guard let auth = WidgetSharedStore.loadAuth() else { throw ClientError.notLogged }

        var authorized = request
        authorized.setValue("Bearer \(auth.accessToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: authorized)
        guard let http = response as? HTTPURLResponse else { throw ClientError.invalidResponse }

        if http.statusCode == 401 {
            let newAccessToken = try await refresh(using: auth)

            var retry = request
            retry.setValue("Bearer \(newAccessToken)", forHTTPHeaderField: "Authorization")

            let (retryData, retryResponse) = try await URLSession.shared.data(for: retry)
            guard let retryHTTP = retryResponse as? HTTPURLResponse,
                  (200 ... 300).contains(retryHTTP.statusCode) else {
                throw ClientError.server
            }
            return retryData
        }

        guard (200 ... 300).contains(http.statusCode) else { throw ClientError.server }
        return data
    }

    @discardableResult
    private func refresh(using auth: WidgetSharedAuth) async throws -> String {
        var request = try makeRequest(path: "user/refresh", method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(
            WidgetRefreshTokenRequest(
                accessToken: auth.accessToken,
                refreshToken: auth.refreshToken
            )
        )

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200 ... 300).contains(http.statusCode) else {
            WidgetSharedStore.clearAuth()
            throw ClientError.notLogged
        }

        let refreshed = try decoder.decode(WidgetRefreshTokenResponse.self, from: data)
        WidgetSharedStore.saveAuth(
            accessToken: refreshed.accessToken,
            refreshToken: refreshed.refreshToken,
            expiresIn: refreshed.expiresIn
        )

        return refreshed.accessToken
    }
}
