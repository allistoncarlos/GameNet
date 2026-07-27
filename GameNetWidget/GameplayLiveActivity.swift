//
//  GameplayLiveActivity.swift
//  GameNetWidget
//
//  UI da Live Activity (Lock Screen + Dynamic Island) para sessão de gameplay.
//

import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Brand

private enum GameNetLiveActivityStyle {
    /// `Color.main` do app (#7B1FA2 / r:0.482 g:0.122 b:0.635).
    static let purple = Color(red: 0.482, green: 0.122, blue: 0.635)
}

// MARK: - Widget

struct GameplayLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GameplayActivityAttributes.self) { context in
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "gamecontroller.fill")
                        .foregroundStyle(GameNetLiveActivityStyle.purple)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.attributes.gameName)
                            .font(.headline)
                            .lineLimit(1)
                        Text(context.attributes.platform)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isPlaying {
                        Text(timerInterval: context.state.sessionStart ... Date.distantFuture, countsDown: false)
                            .monospacedDigit()
                            .font(.title3.weight(.semibold))
                            .frame(width: 70, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                    } else {
                        Text("Encerrado")
                            .font(.caption.weight(.semibold))
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.state.isPlaying ? "Jogando agora" : "Sessão encerrada")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        if context.state.isPlaying {
                            Button(
                                intent: StopGameplayLiveActivityIntent(
                                    userGameId: context.attributes.userGameId,
                                    gameName: context.attributes.gameName,
                                    platform: context.attributes.platform,
                                    coverURL: context.attributes.coverURL
                                )
                            ) {
                                Image(systemName: "stop.fill")
                                    .foregroundStyle(.white)
                                    .frame(width: 28, height: 28)
                                    .background(Circle().fill(GameNetLiveActivityStyle.purple))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            } compactLeading: {
                Image(systemName: "gamecontroller.fill")
                    .foregroundStyle(GameNetLiveActivityStyle.purple)
            } compactTrailing: {
                if context.state.isPlaying {
                    Text(timerInterval: context.state.sessionStart ... Date.distantFuture, countsDown: false)
                        .monospacedDigit()
                        .frame(maxWidth: 52)
                        .font(.caption2.weight(.semibold))
                } else {
                    Image(systemName: "stop.fill")
                        .foregroundStyle(GameNetLiveActivityStyle.purple)
                }
            } minimal: {
                Image(systemName: "gamecontroller.fill")
                    .foregroundStyle(GameNetLiveActivityStyle.purple)
            }
        }
    }

    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<GameplayActivityAttributes>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "gamecontroller.fill")
                .font(.title2)
                .foregroundStyle(GameNetLiveActivityStyle.purple)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(context.attributes.gameName)
                    .font(.headline)
                    .lineLimit(1)
                Text(context.attributes.platform)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                if context.state.isPlaying {
                    Text(timerInterval: context.state.sessionStart ... Date.distantFuture, countsDown: false)
                        .monospacedDigit()
                        .font(.title3.weight(.semibold))
                } else {
                    Text("Sessão encerrada")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)

            if context.state.isPlaying {
                Button(
                    intent: StopGameplayLiveActivityIntent(
                        userGameId: context.attributes.userGameId,
                        gameName: context.attributes.gameName,
                        platform: context.attributes.platform,
                        coverURL: context.attributes.coverURL
                    )
                ) {
                    Image(systemName: "stop.fill")
                        .font(.body.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(GameNetLiveActivityStyle.purple))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .activityBackgroundTint(GameNetLiveActivityStyle.purple.opacity(0.22))
    }
}
