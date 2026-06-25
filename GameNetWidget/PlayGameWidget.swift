//
//  PlayGameWidget.swift
//  GameNetWidget
//
//  Widget de tela inicial: capa preenchida + botão play/stop interativo.
//

import WidgetKit
import SwiftUI

// MARK: - View

struct PlayGameWidgetView: View {
    @Environment(\.widgetFamily) private var family
    var entry: PlayGameEntry

    var body: some View {
        content
            .containerBackground(for: .widget) {
                background
            }
    }

    // MARK: Content states

    @ViewBuilder
    private var content: some View {
        if !entry.isLogged {
            messageView(
                icon: "person.crop.circle.badge.exclamationmark",
                title: "Entre no GameNet",
                subtitle: "Abra o app e faça login."
            )
        } else if let game = entry.game {
            gameView(game)
        } else {
            messageView(
                icon: "gamecontroller",
                title: "Sem jogos",
                subtitle: "Abra o GameNet para sincronizar."
            )
        }
    }

    private func gameView(_ game: WidgetSharedPlayingGame) -> some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading) {
                Spacer()
                Text(game.name)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(family == .systemSmall ? 2 : 1)
                    .shadow(radius: 4)

                if game.isStarted, let start = game.latestStart {
                    Text("Desde \(start.toFormattedString(dateFormat: "HH:mm"))")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.85))
                        .shadow(radius: 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            toggleButton(game)
        }
    }

    private func toggleButton(_ game: WidgetSharedPlayingGame) -> some View {
        Button(intent: ToggleGameplayIntent(userGameId: game.id)) {
            Image(systemName: game.isStarted ? "stop.fill" : "play.fill")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(
                    Circle().fill(game.isStarted ? Color.red : Color.green)
                )
                .shadow(radius: 6)
        }
        .buttonStyle(.plain)
    }

    private func messageView(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
            Text(title)
                .font(.caption.weight(.semibold))
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(8)
    }

    // MARK: Background

    @ViewBuilder
    private var background: some View {
        if entry.isLogged,
           entry.game != nil,
           let data = entry.coverImageData,
           let uiImage = UIImage(data: data) {
            ZStack {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()

                LinearGradient(
                    colors: [.black.opacity(0.0), .black.opacity(0.55)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        } else {
            LinearGradient(
                colors: [Color(.systemGray5), Color(.systemGray3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Widget

struct PlayGameWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetSharedStore.widgetKind, provider: PlayGameProvider()) { entry in
            PlayGameWidgetView(entry: entry)
        }
        .configurationDisplayName("Jogar Agora")
        .description("Inicie ou pare rapidamente a gameplay do seu jogo atual.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Bundle

@main
struct GameNetWidgetBundle: WidgetBundle {
    var body: some Widget {
        PlayGameWidget()
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    PlayGameWidget()
} timeline: {
    PlayGameEntry(date: .now, game: .preview, isLogged: true, coverImageData: nil)
    PlayGameEntry(date: .now, game: nil, isLogged: false, coverImageData: nil)
}
