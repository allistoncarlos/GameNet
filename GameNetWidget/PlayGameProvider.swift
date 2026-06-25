//
//  PlayGameProvider.swift
//  GameNetWidget
//
//  TimelineProvider: lê o cache do App Group, tenta atualizar pela rede,
//  escolhe o jogo-alvo (sessão aberta > último jogado) e baixa a capa.
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

        if isLogged, refreshFromNetwork {
            let client = WidgetGameClient()
            if let fresh = try? await client.fetchPlayingGames() {
                games = fresh
            }
        }

        let game = selectGame(from: games)
        let coverImageData = await loadCover(game?.coverURL)

        return PlayGameEntry(
            date: Date(),
            game: game,
            isLogged: isLogged,
            coverImageData: coverImageData
        )
    }

    private func selectGame(from games: [WidgetSharedPlayingGame]) -> WidgetSharedPlayingGame? {
        if let active = games.first(where: { $0.isStarted }) {
            return active
        }

        return games.max(by: { $0.lastActivityDate < $1.lastActivityDate })
    }

    private func loadCover(_ urlString: String?) async -> Data? {
        guard let urlString,
              !urlString.isEmpty,
              let url = URL(string: urlString) else {
            return nil
        }

        return try? await URLSession.shared.data(from: url).0
    }
}
