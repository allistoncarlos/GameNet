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

struct GameplayLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GameplayActivityAttributes.self) { context in
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "gamecontroller.fill")
                        .foregroundStyle(.green)
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
                        Text("Pausado")
                            .font(.caption.weight(.semibold))
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.state.isPlaying ? "Jogando agora" : "Sessão encerrada")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button(intent: ToggleGameplayIntent(userGameId: context.attributes.userGameId)) {
                            Image(systemName: context.state.isPlaying ? "stop.fill" : "play.fill")
                                .frame(width: 28, height: 28)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } compactLeading: {
                Image(systemName: "gamecontroller.fill")
                    .foregroundStyle(.green)
            } compactTrailing: {
                if context.state.isPlaying {
                    Text(timerInterval: context.state.sessionStart ... Date.distantFuture, countsDown: false)
                        .monospacedDigit()
                        .frame(maxWidth: 52)
                        .font(.caption2.weight(.semibold))
                } else {
                    Image(systemName: "pause.fill")
                }
            } minimal: {
                Image(systemName: "gamecontroller.fill")
                    .foregroundStyle(.green)
            }
        }
    }

    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<GameplayActivityAttributes>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "gamecontroller.fill")
                .font(.title2)
                .foregroundStyle(.green)
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

            Button(intent: ToggleGameplayIntent(userGameId: context.attributes.userGameId)) {
                Image(systemName: context.state.isPlaying ? "stop.fill" : "play.fill")
                    .font(.body.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle().fill(context.state.isPlaying ? Color.red : Color.green)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .activityBackgroundTint(Color.black.opacity(0.35))
    }
}
