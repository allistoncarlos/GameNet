//
//  ToggleGameplayIntent.swift
//  GameNetWidget
//
//  Intent interativo do widget para iniciar/parar a gameplay sem abrir o app.
//

import AppIntents
import WidgetKit

struct ToggleGameplayIntent: AppIntent {
    static var title: LocalizedStringResource = "Iniciar ou parar gameplay"
    static var description = IntentDescription("Inicia ou para a sessão de gameplay do jogo atual.")

    @Parameter(title: "Jogo")
    var userGameId: String

    init() {}

    init(userGameId: String) {
        self.userGameId = userGameId
    }

    func perform() async throws -> some IntentResult {
        var games = WidgetSharedStore.loadPlayingGames()

        guard let game = games.first(where: { $0.id == userGameId }) else {
            WidgetSharedStore.reloadWidget()
            return .result()
        }

        let client = WidgetGameClient()
        let wasStarted = game.isStarted

        if let updated = try? await client.toggleGameplay(for: game) {
            if let index = games.firstIndex(where: { $0.id == updated.id }) {
                games[index] = updated
            }
            WidgetSharedStore.savePlayingGames(games)

            await syncLiveActivity(
                for: updated,
                didStart: !wasStarted && updated.isStarted,
                didStop: wasStarted && !updated.isStarted
            )
        }

        WidgetSharedStore.reloadWidget()
        return .result()
    }

    @MainActor
    private func syncLiveActivity(
        for game: WidgetSharedPlayingGame,
        didStart: Bool,
        didStop: Bool
    ) async {
        if didStart, let start = game.latestStart {
            await GameplayLiveActivityManager.startOrUpdate(
                userGameId: game.id,
                gameName: game.name,
                platform: game.platform,
                coverURL: game.coverURL,
                sessionStart: start
            )
        } else if didStop {
            await GameplayLiveActivityManager.end(userGameId: game.id)
        }
    }
}
