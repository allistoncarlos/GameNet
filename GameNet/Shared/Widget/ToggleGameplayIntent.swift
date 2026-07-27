//
//  ToggleGameplayIntent.swift
//  GameNet
//
//  Intent compartilhada pelo app e pela Widget Extension.
//  Compilada nos dois targets para o sistema preferir executar no processo do app,
//  onde `Activity.request` consegue iniciar a Live Activity.
//

#if os(iOS)
import AppIntents
import Foundation
import WidgetKit

struct ToggleGameplayIntent: AppIntent {
    static var title: LocalizedStringResource = "Iniciar ou parar gameplay"
    static var description = IntentDescription("Inicia ou para a sessão de gameplay do seu jogo atual.")

    /// Preferir execução no app (necessário para iniciar Live Activity).
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Jogo")
    var userGameId: String

    init() {}

    init(userGameId: String) {
        self.userGameId = userGameId
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let games = WidgetSharedStore.loadPlayingGames()

        guard let game = games.first(where: { $0.id == userGameId }) else {
            await GameplayLiveActivityManager.syncFromStore()
            WidgetSharedStore.reloadWidget()
            return .result()
        }

        let client = WidgetGameClient()
        let wasStarted = game.isStarted
        let now = Date.timeZoneDate()

        do {
            let updated = try await client.toggleGameplay(for: game)
            await WidgetSharedStore.upsertSessionAndSyncLiveActivity(
                userGameId: updated.id,
                name: updated.name,
                platform: updated.platform,
                coverURL: updated.coverURL,
                sessionId: updated.latestSessionId,
                start: updated.latestStart ?? now,
                finish: updated.latestFinish
            )
        } catch {
            // Se a API gravou mas o decode falhou (ou resposta incompleta),
            // aplica o estado esperado localmente para widget + Live Activity.
            print("ToggleGameplayIntent: \(error.localizedDescription) — aplicando estado local")
            await WidgetSharedStore.upsertSessionAndSyncLiveActivity(
                userGameId: game.id,
                name: game.name,
                platform: game.platform,
                coverURL: game.coverURL,
                sessionId: game.latestSessionId,
                start: wasStarted ? (game.latestStart ?? now) : now,
                finish: wasStarted ? now : nil
            )
        }

        NotificationCenter.default.post(
            name: .gameplaySessionDidChangeFromWidget,
            object: nil,
            userInfo: ["userGameId": userGameId]
        )

        return .result()
    }
}
#endif
