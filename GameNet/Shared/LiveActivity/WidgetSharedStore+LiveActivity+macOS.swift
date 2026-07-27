//
//  WidgetSharedStore+LiveActivity+macOS.swift
//  GameNet
//

#if os(macOS)
import Foundation

extension WidgetSharedStore {
    @MainActor
    static func persistPlayingGamesAndSyncLiveActivity(
        _ games: [WidgetSharedPlayingGame]
    ) async {
        savePlayingGames(games)
    }

    @MainActor
    static func upsertSessionAndSyncLiveActivity(
        userGameId: String,
        name: String,
        platform: String,
        coverURL: String,
        sessionId: String?,
        start: Date,
        finish: Date?
    ) async {
        var games = loadPlayingGames()
        let updated = WidgetSharedPlayingGame(
            id: userGameId,
            name: name,
            platform: platform,
            coverURL: coverURL,
            latestSessionId: sessionId,
            latestStart: start,
            latestFinish: finish
        )

        if let index = games.firstIndex(where: { $0.id == userGameId }) {
            games[index] = updated
        } else {
            games.insert(updated, at: 0)
        }

        savePlayingGames(games)
    }

    @MainActor
    static func markSessionStoppedAndSyncLiveActivity(userGameId: String) async {
        var games = loadPlayingGames()

        if let index = games.firstIndex(where: { $0.id == userGameId }) {
            if games[index].latestFinish == nil {
                games[index].latestFinish = Date.timeZoneDate()
            }
        }

        savePlayingGames(games)
    }
}
#endif
