//
//  GameplayLiveActivityManager.swift
//  GameNet
//
//  Única fonte de verdade para exibir/esconder a Live Activity de gameplay.
//  Sempre derive o estado a partir da lista de jogos em andamento (App Group).
//

#if os(iOS)
import ActivityKit
import Foundation

@MainActor
enum GameplayLiveActivityManager {

    /// Sincroniza a Live Activity com a lista de jogos em andamento.
    /// Só exibe activity se o jogo da sessão mais recente ainda estiver ativo.
    static func sync(with games: [WidgetSharedPlayingGame]) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        if let preferred = WidgetSharedPlayingGame.preferredForWidget(from: games),
           preferred.isStarted,
           let sessionStart = preferred.latestStart {
            await startOrUpdate(
                userGameId: preferred.id,
                gameName: preferred.name,
                platform: preferred.platform,
                coverURL: preferred.coverURL,
                sessionStart: sessionStart
            )
        } else {
            await endAll()
        }
    }

    /// Lê o App Group e sincroniza (útil no launch do app).
    static func syncFromStore() async {
        await sync(with: WidgetSharedStore.loadPlayingGames())
    }

    /// Inicia (ou atualiza) a Live Activity de um jogo em sessão.
    static func startOrUpdate(
        userGameId: String,
        gameName: String,
        platform: String,
        coverURL: String,
        sessionStart: Date
    ) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = GameplayActivityAttributes(
            userGameId: userGameId,
            gameName: gameName,
            platform: platform,
            coverURL: coverURL
        )
        // `sessionStart` costuma vir de `timeZoneDate()` / API (horário local deslocado).
        // O timer da Live Activity usa instante absoluto — desfaz o shift do fuso (UTC−3 em Goiânia).
        let absoluteSessionStart = sessionStart.undoingTimeZoneDateShift()
        let content = ActivityContent(
            state: GameplayActivityAttributes.ContentState(
                isPlaying: true,
                sessionStart: absoluteSessionStart
            ),
            staleDate: nil
        )

        if let existing = Activity<GameplayActivityAttributes>.activities.first(where: {
            $0.attributes.userGameId == userGameId
        }) {
            await existing.update(content)
            // Encerra activities de outros jogos, se houver.
            for activity in Activity<GameplayActivityAttributes>.activities
            where activity.id != existing.id {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            return
        }

        await endAll()

        do {
            _ = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            print("Live Activity: falha ao iniciar — \(error.localizedDescription)")
        }
    }

    /// Encerra a Live Activity do jogo (ou todas, se `userGameId` for nil).
    static func end(userGameId: String?) async {
        let activities = Activity<GameplayActivityAttributes>.activities.filter { activity in
            guard let userGameId else { return true }
            return activity.attributes.userGameId == userGameId
        }

        for activity in activities {
            let finalState = GameplayActivityAttributes.ContentState(
                isPlaying: false,
                sessionStart: activity.content.state.sessionStart
            )
            await activity.end(
                ActivityContent(state: finalState, staleDate: nil),
                dismissalPolicy: .immediate
            )
        }
    }

    static func endAll() async {
        await end(userGameId: nil)
    }
}
#endif
