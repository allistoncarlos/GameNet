//
//  PlayGameProvider.swift
//  GameNetWidget
//
//  TimelineProvider: lê o cache do App Group, tenta atualizar pela rede,
//  escolhe o jogo da GameplaySession mais recente e baixa a capa.
//

import WidgetKit
import Foundation

// MARK: - PlayGameEntry

struct PlayGameEntry: TimelineEntry {
    let date: Date
    let game: WidgetSharedPlayingGame?
    let isLogged: Bool
    let coverImageData: Data?
}

extension WidgetSharedPlayingGame {
    static let preview = WidgetSharedPlayingGame(
        id: "preview",
        name: "The Legend of Zelda: Tears of the Kingdom",
        platform: "Nintendo Switch",
        coverURL: "",
        latestSessionId: nil,
        latestStart: nil,
        latestFinish: nil
    )
}

// MARK: - PlayGameProvider

struct PlayGameProvider: TimelineProvider {
    func placeholder(in context: Context) -> PlayGameEntry {
        PlayGameEntry(
            date: Date(),
            game: .preview,
            isLogged: true,
            coverImageData: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PlayGameEntry) -> Void) {
        Task {
            completion(await makeEntry(refreshFromNetwork: !context.isPreview))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PlayGameEntry>) -> Void) {
        Task {
            // Após um tap no botão, o cache local já está atualizado — prioriza ele
            // e só então tenta rede (sem cache HTTP), sem sobrescrever sessão ativa recente.
            let entry = await makeEntry(refreshFromNetwork: true)
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())
                ?? Date().addingTimeInterval(15 * 60)

            completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
        }
    }

    // MARK: Private

    private func makeEntry(refreshFromNetwork: Bool) async -> PlayGameEntry {
        let isLogged = WidgetSharedStore.isLogged
        var games = WidgetSharedStore.loadPlayingGames()
        let localActive = games
            .filter(\.isStarted)
            .max { $0.lastActivityDate < $1.lastActivityDate }

        if isLogged, refreshFromNetwork {
            let client = WidgetGameClient()
            if let fresh = try? await client.fetchPlayingGames() {
                // Se o local acabou de marcar sessão ativa e a rede ainda não refletiu,
                // preserva o estado local para o widget/Live Activity não "voltarem atrás".
                // Não preserva sessão aberta antiga quando a rede já tem atividade mais nova.
                let remoteActive = fresh.first(where: \.isStarted)
                if let localActive,
                   remoteActive == nil,
                   WidgetSharedPlayingGame.shouldKeepLocalActive(localActive, over: fresh) {
                    games = mergePreferringLocalActive(local: games, remote: fresh, active: localActive)
                    await WidgetSharedStore.persistPlayingGamesAndSyncLiveActivity(games)
                } else {
                    games = fresh
                }
            }
        }

        let game = WidgetSharedPlayingGame.preferredForWidget(from: games)
        let coverImageData = await loadCover(game?.coverURL)

        return PlayGameEntry(
            date: Date(),
            game: game,
            isLogged: isLogged,
            coverImageData: coverImageData
        )
    }

    private func mergePreferringLocalActive(
        local: [WidgetSharedPlayingGame],
        remote: [WidgetSharedPlayingGame],
        active: WidgetSharedPlayingGame
    ) -> [WidgetSharedPlayingGame] {
        var merged = remote
        if let index = merged.firstIndex(where: { $0.id == active.id }) {
            merged[index] = active
        } else {
            merged.insert(active, at: 0)
        }
        return merged
    }

    private func loadCover(_ urlString: String?) async -> Data? {
        guard let urlString,
              !urlString.isEmpty,
              let url = URL(string: urlString) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        return try? await URLSession.shared.data(for: request).0
    }
}
