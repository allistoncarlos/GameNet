//
//  WidgetSharedStore+LiveActivity.swift
//  GameNet
//
//  Ponte App Group ↔ Live Activity. Qualquer play/stop (app ou widget)
//  deve passar por aqui para a activity aparecer/desaparecer de forma consistente.
//

import Foundation

extension WidgetSharedStore {

    /// Persiste a lista, sincroniza a Live Activity e recarrega o widget.
    @MainActor
    static func persistPlayingGamesAndSyncLiveActivity(
        _ games: [WidgetSharedPlayingGame]
    ) async {
        savePlayingGames(games)
        await GameplayLiveActivityManager.sync(with: games)
        reloadWidget()
    }

    /// Atualiza (ou insere) a sessão de um jogo e sincroniza a Live Activity.
    /// - `finish == nil` → sessão ativa → activity aparece
    /// - `finish != nil` → sessão parada → activity desaparece
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

        await persistPlayingGamesAndSyncLiveActivity(games)
    }

    /// Marca a sessão do jogo como encerrada e sincroniza (activity some).
    @MainActor
    static func markSessionStoppedAndSyncLiveActivity(userGameId: String) async {
        var games = loadPlayingGames()

        if let index = games.firstIndex(where: { $0.id == userGameId }) {
            if games[index].latestFinish == nil {
                games[index].latestFinish = Date.timeZoneDate()
            }
        }

        await persistPlayingGamesAndSyncLiveActivity(games)
    }
}
