//
//  GameplayLiveActivityManager.swift
//  GameNet
//
//  Inicia, atualiza e encerra Live Activities de sessão de gameplay.
//

import ActivityKit
import Foundation

@MainActor
enum GameplayLiveActivityManager {
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
        let state = GameplayActivityAttributes.ContentState(
            isPlaying: true,
            sessionStart: sessionStart
        )

        // Se já existe activity para este jogo, só atualiza.
        if let existing = Activity<GameplayActivityAttributes>.activities.first(where: {
            $0.attributes.userGameId == userGameId
        }) {
            await existing.update(ActivityContent(state: state, staleDate: nil))
            return
        }

        // Encerra outras activities de gameplay para manter uma por vez.
        for activity in Activity<GameplayActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }

        do {
            _ = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("Live Activity: falha ao iniciar — \(error.localizedDescription)")
        }
    }

    /// Encerra a Live Activity do jogo (ou todas, se id nil).
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
                dismissalPolicy: .after(.now + 2)
            )
        }
    }
}
