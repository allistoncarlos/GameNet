//
//  WidgetSharedStore+App.swift
//  GameNet
//
//  Conversões e sincronização do app para o App Group consumido pelo widget.
//  Este arquivo pertence apenas ao target do app (usa GameNet.Network/Keychain).
//

import Foundation
import GameNet_Keychain

extension WidgetSharedStore {
    /// Persiste a lista de jogos em andamento vinda do dashboard e recarrega o widget.
    static func savePlayingGames(from playingGames: [PlayingGame]) {
        let mapped: [WidgetSharedPlayingGame] = playingGames.compactMap { game in
            guard let id = game.id else { return nil }

            return WidgetSharedPlayingGame(
                id: id,
                name: game.name,
                platform: game.platform,
                coverURL: game.coverURL,
                latestSessionId: game.latestGameplaySession?.id,
                latestStart: game.latestGameplaySession?.start,
                latestFinish: game.latestGameplaySession?.finish
            )
        }

        savePlayingGames(mapped)
        reloadWidget()
    }

    /// Sincroniza token e baseURL a partir do Keychain/Info.plist (uso no launch e login).
    static func syncFromKeychain() {
        if let baseURL = Bundle.main.infoDictionary?["API_PATH"] as? String {
            saveAPIBaseURL(baseURL)
        }

        guard KeychainDataSource.hasValidToken(),
              let accessToken = KeychainDataSource.accessToken.get(),
              let refreshToken = KeychainDataSource.refreshToken.get() else {
            clearAuth()
            return
        }

        let expiresIn = KeychainDataSource.expiresIn.get()
            .flatMap { ISO8601DateFormatter().date(from: $0) }

        saveAuth(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: expiresIn
        )

        reloadWidget()
    }
}
