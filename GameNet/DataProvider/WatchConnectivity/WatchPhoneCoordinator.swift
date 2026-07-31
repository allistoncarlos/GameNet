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

    private var periodicSyncTask: Task<Void, Never>?
    private let periodicSyncInterval: TimeInterval = 300

    /// Limite prático seguro para `sendMessage` reply (~65KB oficial, deixamos margem).
    private let sendMessageBudget = 55_000

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

    /// Empurra jogos em andamento, status de auth e capas (já convertidas em JPEG) para
    /// o Watch via application context — entrega confiável em uma única chamada.
    func pushPlayingGamesToWatch() async {
        guard WCSession.default.activationState == .activated,
              WCSession.default.isPaired,
              WCSession.default.isWatchAppInstalled else {
            return
        }

        let authStatus: WatchAuthStatus = tokenDataSource.hasValidToken() ? .logged : .notLogged

        guard authStatus == .logged else {
            pushContext(games: [], authStatus: .notLogged, covers: [:])
            return
        }

        let games = await loadPlayingGames()
        let covers = games.isEmpty ? [:] : await WatchCoverImageExporter.thumbnails(for: games)
        pushContext(games: games, authStatus: .logged, covers: covers)
    }

    func startPeriodicWatchSync() {
        periodicSyncTask?.cancel()
        periodicSyncTask = Task { [weak self] in
            guard let self else { return }

            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(periodicSyncInterval * 1_000_000_000))
                guard !Task.isCancelled else { return }
                await pushPlayingGamesToWatch()
            }
        }
    }

    // MARK: Private

    private func handleCheckAuth() -> [String: Any] {
        let status: WatchAuthStatus = tokenDataSource.hasValidToken() ? .logged : .notLogged
        return [WatchMessageKey.authStatus: status.rawValue]
    }

    private func handleFetchPlayingGames() async -> [String: Any] {
        guard tokenDataSource.hasValidToken() else {
            pushContext(games: [], authStatus: .notLogged, covers: [:])
            return [WatchMessageKey.authStatus: WatchAuthStatus.notLogged.rawValue]
        }

        let games = await loadPlayingGames()
        let covers = games.isEmpty ? [:] : await WatchCoverImageExporter.thumbnails(for: games)
        pushContext(games: games, authStatus: .logged, covers: covers)

        return buildFetchReply(games: games, covers: covers)
    }

    private func handleToggleGameplay(_ request: WatchToggleGameplayRequest) async -> [String: Any] {
        guard tokenDataSource.hasValidToken() else {
            pushContext(games: [], authStatus: .notLogged, covers: [:])
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
        let covers = games.isEmpty ? [:] : await WatchCoverImageExporter.thumbnails(for: games)
        pushContext(games: games, authStatus: .logged, covers: covers)

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

    /// Envia metadados + capas (JPEGs pequenos) em um único `updateApplicationContext`.
    /// `updateApplicationContext` aceita ~262KB — cabe 20+ capas de ~10KB folgadamente.
    private func pushContext(
        games: [WatchPlayingGame],
        authStatus: WatchAuthStatus,
        covers: [String: Data]
    ) {
        guard WCSession.default.activationState == .activated,
              let gamesData = WatchConnectivityPayloadCodec.encode(WatchPlayingGamesPayload(games: games)) else {
            return
        }

        var context: [String: Any] = [
            WatchMessageKey.authStatus: authStatus.rawValue,
            WatchMessageKey.playingGames: gamesData
        ]

        if !covers.isEmpty {
            context[WatchMessageKey.playingGameCovers] = covers as NSDictionary
        }

        try? WCSession.default.updateApplicationContext(context)
    }

    /// Monta o reply do `sendMessage`. Inclui capas se couberem no orçamento (~55KB),
    /// senão o Watch continua tendo as capas via application context.
    private func buildFetchReply(games: [WatchPlayingGame], covers: [String: Data]) -> [String: Any] {
        guard let gamesData = WatchConnectivityPayloadCodec.encode(WatchPlayingGamesPayload(games: games)) else {
            return [WatchMessageKey.error: "encode_failed"]
        }

        var reply: [String: Any] = [WatchMessageKey.playingGames: gamesData]

        let coversSize = covers.values.reduce(0) { $0 + $1.count }
        if !covers.isEmpty, coversSize + gamesData.count < sendMessageBudget {
            reply[WatchMessageKey.playingGameCovers] = covers as NSDictionary
        }

        return reply
    }
}
#endif
