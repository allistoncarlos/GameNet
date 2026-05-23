//
//  WatchPlayingGamesService.swift
//  GameNet.Watch Watch App
//
//  Created by Alliston Aleixo on 23/05/26.
//

import Foundation

enum WatchPlayingGamesServiceError: LocalizedError {
    case notLogged
    case unreachable
    case invalidResponse
    case server(String)

    var errorDescription: String? {
        switch self {
        case .notLogged:
            return "Faça login no iPhone para continuar."
        case .unreachable:
            return "Abra o GameNet no iPhone para sincronizar."
        case .invalidResponse:
            return "Não foi possível ler os dados do iPhone."
        case let .server(message):
            return message
        }
    }
}

final class WatchPlayingGamesService {
    func checkAuth() async throws {
        try await Task.sleep(nanoseconds: 10_000_000)
        
        if WatchConnectivityManager.shared.state == .activated {
            try await withCheckedThrowingContinuation { continuation in
                WatchConnectivityManager.shared.sendMessage(
                    key: WatchMessageKey.checkAuth,
                    replyHandler: { reply in
                        if reply[WatchMessageKey.authStatus] as? String == WatchAuthStatus.logged.rawValue {
                            continuation.resume(returning: true)
                        } else {
                            continuation.resume(throwing: WatchPlayingGamesServiceError.notLogged)
                        }
                    },
                    errorHandler: { _ in
                        continuation.resume(throwing: WatchPlayingGamesServiceError.unreachable)
                    }
                )
            }
        }
    }

    func fetchPlayingGames() async throws -> [WatchPlayingGame] {
        if let cached = cachedPlayingGames(), !cached.isEmpty {
            Task { await refreshPlayingGamesInBackground() }
            return cached
        }

        return try await requestPlayingGames()
    }

    func toggleGameplay(
        game: WatchPlayingGame,
        habitDayISO: String
    ) async throws -> WatchPlayingGame {
        let request = WatchToggleGameplayRequest(
            userGameId: game.id,
            isCurrentlyStarted: game.isStarted,
            latestSessionStartISO: game.latestSessionStartISO,
            habitDayISO: habitDayISO
        )

        guard let payload = WatchConnectivityPayloadCodec.encode(request) else {
            throw WatchPlayingGamesServiceError.invalidResponse
        }

        return try await withCheckedThrowingContinuation { continuation in
            WatchConnectivityManager.shared.sendMessage(
                message: payload,
                key: WatchMessageKey.toggleGameplay,
                replyHandler: { reply in
                    if reply[WatchMessageKey.authStatus] as? String == WatchAuthStatus.notLogged.rawValue {
                        continuation.resume(throwing: WatchPlayingGamesServiceError.notLogged)
                        return
                    }

                    if let errorMessage = reply[WatchMessageKey.error] as? String {
                        continuation.resume(throwing: WatchPlayingGamesServiceError.server(errorMessage))
                        return
                    }

                    guard let data = reply[WatchMessageKey.gameplayUpdated] as? Data,
                          let updated = WatchConnectivityPayloadCodec.decode(
                            WatchGameplayUpdatedPayload.self,
                            from: data
                          ) else {
                        continuation.resume(throwing: WatchPlayingGamesServiceError.invalidResponse)
                        return
                    }

                    let merged = WatchPlayingGame(
                        id: game.id,
                        name: game.name,
                        coverURL: game.coverURL,
                        latestSessionStartISO: updated.latestSessionStartISO,
                        isSessionActive: updated.isSessionActive
                    )
                    continuation.resume(returning: merged)
                },
                errorHandler: { _ in
                    continuation.resume(throwing: WatchPlayingGamesServiceError.unreachable)
                }
            )
        }
    }

    // MARK: Private

    private func refreshPlayingGamesInBackground() async {
        _ = try? await requestPlayingGames()
    }

    private func requestPlayingGames() async throws -> [WatchPlayingGame] {
        try await withCheckedThrowingContinuation { continuation in
            WatchConnectivityManager.shared.sendMessage(
                key: WatchMessageKey.fetchPlayingGames,
                replyHandler: { reply in
                    if reply[WatchMessageKey.authStatus] as? String == WatchAuthStatus.notLogged.rawValue {
                        continuation.resume(throwing: WatchPlayingGamesServiceError.notLogged)
                        return
                    }

                    if let errorMessage = reply[WatchMessageKey.error] as? String {
                        continuation.resume(throwing: WatchPlayingGamesServiceError.server(errorMessage))
                        return
                    }

                    guard let data = reply[WatchMessageKey.playingGames] as? Data,
                          let payload = WatchConnectivityPayloadCodec.decode(
                            WatchPlayingGamesPayload.self,
                            from: data
                          ) else {
                        continuation.resume(throwing: WatchPlayingGamesServiceError.invalidResponse)
                        return
                    }

                    continuation.resume(returning: payload.games)
                },
                errorHandler: { [weak self] _ in
                    if let cached = self?.cachedPlayingGames(), !cached.isEmpty {
                        continuation.resume(returning: cached)
                    } else {
                        continuation.resume(throwing: WatchPlayingGamesServiceError.unreachable)
                    }
                }
            )
        }
    }

    private func cachedPlayingGames() -> [WatchPlayingGame]? {
        WatchConnectivityManager.shared.playingGamesFromContext()?.games
    }
}
