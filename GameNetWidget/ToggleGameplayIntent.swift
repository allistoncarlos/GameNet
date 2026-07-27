//
//  ToggleGameplayIntent.swift
//  GameNetWidget
//
//  Intent interativo do widget / Live Activity para iniciar/parar a gameplay.
//

import AppIntents
import WidgetKit

struct ToggleGameplayIntent: AppIntent {
    static var title: LocalizedStringResource = "Iniciar ou parar gameplay"
    static var description = IntentDescription("Inicia ou para a sessão de gameplay do seu jogo atual.")

    @Parameter(title: "Jogo")
    var userGameId: String

    init() {}

    init(userGameId: String) {
        self.userGameId = userGameId
    }

    func perform() async throws -> some IntentResult {
        var games = WidgetSharedStore.loadPlayingGames()

        guard let game = games.first(where: { $0.id == userGameId }) else {
            await GameplayLiveActivityManager.syncFromStore()
            WidgetSharedStore.reloadWidget()
            return .result()
        }

        let client = WidgetGameClient()

        if let updated = try? await client.toggleGameplay(for: game) {
            await WidgetSharedStore.upsertSessionAndSyncLiveActivity(
                userGameId: updated.id,
                name: updated.name,
                platform: updated.platform,
                coverURL: updated.coverURL,
                sessionId: updated.latestSessionId,
                start: updated.latestStart ?? Date.timeZoneDate(),
                finish: updated.latestFinish
            )
        } else {
            // Mesmo em falha de rede, tenta alinhar a activity ao cache local.
            await GameplayLiveActivityManager.syncFromStore()
            WidgetSharedStore.reloadWidget()
        }

        return .result()
    }
}
