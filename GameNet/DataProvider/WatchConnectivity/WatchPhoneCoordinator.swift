//
//  WatchPhoneCoordinator.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/05/26.
//

#if os(iOS) && canImport(WatchConnectivity)
import Factory
import Foundation
import WatchConnectivity

// MARK: - WatchPhoneCoordinator

@MainActor
final class WatchPhoneCoordinator {
    static let shared = WatchPhoneCoordinator()

    @Injected(\.dashboardRepository) private var dashboardRepository
    @Injected(\.gameplaySessionRepository) private var gameplaySessionRepository
    @Injected(\.tokenDataSource) private var tokenDataSource

    func handle(message: [String: Any]) async -> [String: Any] {
        if message[WatchMessageKey.checkAuth] != nil {
            return handleCheckAuth()
        }

        if message[WatchMessageKey.fetchPlayingGames] != nil {
            return await handleFetchPlayingGames()
        }

        if let data = message[WatchMessageKey.toggleGameplay] as? Data,
           let request = WatchConnectivityPayloadCodec.decode(WatchToggleGameplayRequest.self, from: data) {
            return await handleToggleGameplay(request)
        }

        return [:]
    }

    // MARK: Private

    private func handleCheckAuth() -> [String: Any] {
        let status: WatchAuthStatus = tokenDataSource.hasValidToken() ? .logged : .notLogged
        return [WatchMessageKey.authStatus: status.rawValue]
    }

    private func handleFetchPlayingGames() async -> [String: Any] {
        guard tokenDataSource.hasValidToken() else {
            return [WatchMessageKey.authStatus: WatchAuthStatus.notLogged.rawValue]
        }

        let games = await loadPlayingGames()
        cachePlayingGamesOnWatch(games)

        return WatchConnectivityPayloadCodec.reply(
            WatchMessageKey.playingGames,
            value: WatchPlayingGamesPayload(games: games)
        ) ?? [WatchMessageKey.error: "encode_failed"]
    }

    private func handleToggleGameplay(_ request: WatchToggleGameplayRequest) async -> [String: Any] {
        guard tokenDataSource.hasValidToken() else {
            return [WatchMessageKey.authStatus: WatchAuthStatus.notLogged.rawValue]
        }

        let start: Date
        let finish: Date?

        if request.isCurrentlyStarted {
            if let latestStartISO = request.latestSessionStartISO,
               let latestStart = WatchConnectivityDateCodec.date(fromISO: latestStartISO) {
                start = latestStart
            } else {
                start = Date.timeZoneDate()
            }
            finish = Date.timeZoneDate()
        } else {
            start = Date.timeZoneDate()
            finish = nil
        }

        guard let session = await gameplaySessionRepository.save(
            userGameId: request.userGameId,
            start: start,
            finish: finish,
            id: nil
        ) else {
            return [WatchMessageKey.error: "save_failed"]
        }

        let games = await loadPlayingGames()
        cachePlayingGamesOnWatch(games)

        let payload = WatchGameplayUpdatedPayload(
            userGameId: request.userGameId,
            latestSessionStartISO: WatchConnectivityDateCodec.isoString(from: session.start),
            isSessionActive: session.finish == nil
        )

        return WatchConnectivityPayloadCodec.reply(
            WatchMessageKey.gameplayUpdated,
            value: payload
        ) ?? [WatchMessageKey.error: "encode_failed"]
    }

    private func loadPlayingGames() async -> [WatchPlayingGame] {
        guard let dashboard = await dashboardRepository.fetchData(),
              let playingGames = dashboard.playingGames else {
            return []
        }

        return mapPlayingGames(playingGames)
    }

    private func mapPlayingGames(_ playingGames: [PlayingGame]) -> [WatchPlayingGame] {
        let ordered = playingGames.sorted { lhs, rhs in
            if let lhsDate = lhs.latestGameplaySession?.finish,
               let rhsDate = rhs.latestGameplaySession?.finish {
                return lhsDate > rhsDate
            }
            return true
        }

        return ordered.compactMap { game in
            guard let id = game.id else { return nil }

            let latestSession = game.latestGameplaySession
            return WatchPlayingGame(
                id: id,
                name: game.name,
                coverURL: game.coverURL,
                latestSessionStartISO: latestSession.map {
                    WatchConnectivityDateCodec.isoString(from: $0.start)
                },
                isSessionActive: latestSession?.finish == nil && latestSession != nil
            )
        }
    }

    private func cachePlayingGamesOnWatch(_ games: [WatchPlayingGame]) {
        guard WCSession.default.activationState == .activated,
              let data = WatchConnectivityPayloadCodec.encode(WatchPlayingGamesPayload(games: games)) else {
            return
        }

        try? WCSession.default.updateApplicationContext([WatchMessageKey.playingGames: data])
    }
}
#endif
