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

@MainActor
final class WatchPlayingGamesService {
    func checkAuth() async throws {
        await WatchConnectivityManager.shared.waitForActivation()
        WatchConnectivityManager.shared.refreshCachedPayload()

        if let cachedStatus = WatchConnectivityManager.shared.cachedAuthStatus {
            if cachedStatus == .notLogged {
                throw WatchPlayingGamesServiceError.notLogged
            }
            return
        }

        guard WatchConnectivityManager.shared.isReachable else {
            throw WatchPlayingGamesServiceError.unreachable
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Task {
                await WatchConnectivityManager.shared.sendMessageWithTimeout(
                    key: WatchMessageKey.checkAuth,
                    timeout: 8,
                    replyHandler: { reply in
                        if reply[WatchMessageKey.authStatus] as? String == WatchAuthStatus.logged.rawValue {
                            continuation.resume()
                        } else {
                            continuation.resume(throwing: WatchPlayingGamesServiceError.notLogged)
                        }
                    },
                    errorHandler: { error in
                        continuation.resume(throwing: error)
                    }
                )
            }
        }
    }

    func fetchPlayingGames(forceRefresh: Bool = false) async throws -> [WatchPlayingGame] {
        await WatchConnectivityManager.shared.waitForActivation()
        WatchConnectivityManager.shared.refreshCachedPayload()

        if !forceRefresh, let cached = cachedPlayingGames() {
            if WatchConnectivityManager.shared.isReachable {
                Task { try? await requestPlayingGames() }
            }
            return cached
        }

        if let cached = cachedPlayingGames(), !WatchConnectivityManager.shared.isReachable {
            return cached
        }

        return try await requestPlayingGames()
    }

    func toggleGameplay(
        game: WatchPlayingGame,
        habitDayISO: String
    ) async throws -> WatchPlayingGame {
        await WatchConnectivityManager.shared.waitForActivation()

        let request = WatchToggleGameplayRequest(
            userGameId: game.id,
            isCurrentlyStarted: game.isStarted,
            latestSessionStartISO: game.latestSessionStartISO,
            habitDayISO: habitDayISO
        )

        guard let payload = WatchConnectivityPayloadCodec.encode(request) else {
            throw WatchPlayingGamesServiceError.invalidResponse
        }

        guard WatchConnectivityManager.shared.isReachable else {
            throw WatchPlayingGamesServiceError.unreachable
        }

        return try await withCheckedThrowingContinuation { continuation in
            Task {
                await WatchConnectivityManager.shared.sendMessageWithTimeout(
                    message: payload,
                    key: WatchMessageKey.toggleGameplay,
                    timeout: 12,
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
                        WatchConnectivityManager.shared.refreshCachedPayload()
                        continuation.resume(returning: merged)
                    },
                    errorHandler: { error in
                        if let cached = self.cachedPlayingGames()?.first(where: { $0.id == game.id }) {
                            continuation.resume(returning: cached)
                        } else {
                            continuation.resume(throwing: error)
                        }
                    }
                )
            }
        }
    }

    // MARK: Private

    private func requestPlayingGames() async throws -> [WatchPlayingGame] {
        if !WatchConnectivityManager.shared.isReachable {
            if let cached = cachedPlayingGames() {
                return cached
            }
            throw WatchPlayingGamesServiceError.unreachable
        }

        return try await withCheckedThrowingContinuation { continuation in
            Task {
                await WatchConnectivityManager.shared.sendMessageWithTimeout(
                    key: WatchMessageKey.fetchPlayingGames,
                    timeout: 8,
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
                            if let cached = self.cachedPlayingGames() {
                                continuation.resume(returning: cached)
                            } else {
                                continuation.resume(throwing: WatchPlayingGamesServiceError.invalidResponse)
                            }
                            return
                        }

                        WatchConnectivityManager.shared.persistPayload(payload)
                        WatchConnectivityManager.shared.ingestCovers(from: reply)
                        continuation.resume(returning: payload.games)
                    },
                    errorHandler: { _ in
                        if let cached = self.cachedPlayingGames() {
                            continuation.resume(returning: cached)
                        } else {
                            continuation.resume(throwing: WatchPlayingGamesServiceError.unreachable)
                        }
                    }
                )
            }
        }
    }

    private func cachedPlayingGames() -> [WatchPlayingGame]? {
        guard let payload = WatchConnectivityManager.shared.playingGamesFromContext() else {
            return nil
        }
        return payload.games
    }
}
