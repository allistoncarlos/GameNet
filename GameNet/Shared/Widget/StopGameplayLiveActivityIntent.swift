//
//  StopGameplayLiveActivityIntent.swift
//  GameNet
//
//  Intent exclusiva da Live Activity / Dynamic Island.
//  Conforma a LiveActivityIntent para o sistema executar no processo do app
//  (AppIntent puro no botão da LA frequentemente não chama perform()).
//

#if os(iOS)
import AppIntents
import Foundation
import WidgetKit

struct StopGameplayLiveActivityIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Parar gameplay"
    static var description = IntentDescription("Encerra a sessão de gameplay ativa.")

    @Parameter(title: "Jogo")
    var userGameId: String

    @Parameter(title: "Nome")
    var gameName: String

    @Parameter(title: "Plataforma")
    var platform: String

    @Parameter(title: "Capa")
    var coverURL: String

    init() {
        userGameId = ""
        gameName = ""
        platform = ""
        coverURL = ""
    }

    init(userGameId: String, gameName: String, platform: String, coverURL: String) {
        self.userGameId = userGameId
        self.gameName = gameName
        self.platform = platform
        self.coverURL = coverURL
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let games = WidgetSharedStore.loadPlayingGames()
        let cached = games.first(where: { $0.id == userGameId })
        let now = Date.timeZoneDate()
        let start = cached?.latestStart ?? now

        let game = cached ?? WidgetSharedPlayingGame(
            id: userGameId,
            name: gameName,
            platform: platform,
            coverURL: coverURL,
            latestSessionId: nil,
            latestStart: start,
            latestFinish: nil
        )

        do {
            let updated = try await WidgetGameClient().stopGameplay(for: game)
            await WidgetSharedStore.upsertSessionAndSyncLiveActivity(
                userGameId: updated.id,
                name: updated.name.isEmpty ? gameName : updated.name,
                platform: updated.platform.isEmpty ? platform : updated.platform,
                coverURL: updated.coverURL.isEmpty ? coverURL : updated.coverURL,
                sessionId: updated.latestSessionId,
                start: updated.latestStart ?? start,
                finish: updated.latestFinish ?? now
            )
        } catch {
            print("StopGameplayLiveActivityIntent: \(error.localizedDescription) — encerrando localmente")
            await WidgetSharedStore.upsertSessionAndSyncLiveActivity(
                userGameId: userGameId,
                name: gameName,
                platform: platform,
                coverURL: coverURL,
                sessionId: game.latestSessionId,
                start: start,
                finish: now
            )
            // Garante que a activity some mesmo se o sync pelo store falhar.
            await GameplayLiveActivityManager.end(userGameId: userGameId)
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
