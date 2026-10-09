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

    private var isExtraLarge: Bool {
        if family == .systemExtraLarge { return true }
        if #available(iOSApplicationExtension 27.0, *) {
            return family == .systemExtraLargePortrait
        }
        return false
    }

    var body: some View {
        if #available(iOS 17.0, *) {
            content
                .containerBackground(for: .widget) {
                    background
                }
        } else {
            // iOS 16: sem `containerBackground` nem margens automáticas do sistema.
            content
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(background)
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
            if isExtraLarge {
                extraLargeGameView(game)
            } else {
                gameView(game)
            }
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
            VStack(alignment: .leading, spacing: gameInfoSpacing) {
                Spacer()

                if family == .systemLarge, !game.platform.isEmpty {
                    Text(game.platform)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(1)
                        .shadow(radius: 4)
                }

                Text(game.name)
                    .font(gameNameFont)
                    .foregroundStyle(.white)
                    .lineLimit(gameNameLineLimit)
                    .shadow(radius: 4)

                if game.isStarted, let start = game.latestStart {
                    Text("Desde \(start.toFormattedString(dateFormat: "HH:mm"))")
                        .font(sessionTimeFont)
                        .foregroundStyle(.white.opacity(0.85))
                        .shadow(radius: 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(family == .systemLarge ? 4 : 0)

            toggleButton(game)
        }
    }

    private func extraLargeGameView(_ game: WidgetSharedPlayingGame) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Label(
                    game.isStarted ? "Em gameplay" : "Pronto para jogar",
                    systemImage: game.isStarted ? "record.circle.fill" : "gamecontroller.fill"
                )
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.95))
                .labelStyle(.titleAndIcon)
                .shadow(radius: 4)

                Spacer()
            }

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 10) {
                if !game.platform.isEmpty {
                    Text(game.platform.uppercased())
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.85))
                        .tracking(0.6)
                        .lineLimit(1)
                }

                Text(game.name)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(4)
                    .minimumScaleFactor(0.85)
                    .shadow(radius: 6)

                if game.isStarted, let start = game.latestStart {
                    Text("Desde \(start.toFormattedString(dateFormat: "HH:mm"))")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.white.opacity(0.9))
                        .shadow(radius: 4)
                }

                HStack {
                    Spacer()
                    toggleButton(game)
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(20)
    }

    private var gameInfoSpacing: CGFloat {
        if family == .systemLarge { return 4 }
        return 2
    }

    private var gameNameLineLimit: Int {
        switch family {
        case .systemSmall: return 2
        case .systemMedium: return 1
        case .systemLarge: return 3
        default: return 1
        }
    }

    private var gameNameFont: Font {
        if family == .systemLarge { return .subheadline.weight(.semibold) }
        return .caption.weight(.semibold)
    }

    private var sessionTimeFont: Font {
        if family == .systemLarge { return .caption }
        return .caption2
    }

    @ViewBuilder
    private func toggleButton(_ game: WidgetSharedPlayingGame) -> some View {
        if #available(iOS 17.0, *) {
            Button(intent: ToggleGameplayIntent(userGameId: game.id)) {
                toggleLabel(game)
            }
            .buttonStyle(.plain)
        } else {
            // iOS 16 não suporta widgets interativos: o ícone só indica o estado
            // e o toque no widget abre o app.
            toggleLabel(game)
        }
    }

    private func toggleLabel(_ game: WidgetSharedPlayingGame) -> some View {
        Image(systemName: game.isStarted ? "stop.fill" : "play.fill")
            .font(toggleIconFont.weight(.bold))
            .foregroundStyle(.white)
            .frame(width: toggleButtonSize, height: toggleButtonSize)
            .background(
                Circle().fill(game.isStarted ? Color.red : Color.green)
            )
            .shadow(radius: 6)
    }

    private var toggleButtonSize: CGFloat {
        if isExtraLarge { return 72 }
        if family == .systemLarge { return 54 }
        return 46
    }

    private var toggleIconFont: Font {
        if isExtraLarge { return .largeTitle }
        if family == .systemLarge { return .title2 }
        return .title3
    }

    private func messageView(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: isExtraLarge ? 14 : (family == .systemLarge ? 10 : 6)) {
            Image(systemName: icon)
                .font(isExtraLarge ? .system(size: 52) : (family == .systemLarge ? .title : .title2))
            Text(title)
                .font(isExtraLarge ? .title2.weight(.semibold) : .caption.weight(.semibold))
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(isExtraLarge ? .body : (family == .systemLarge ? .subheadline : .caption2))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(isExtraLarge ? 28 : (family == .systemLarge ? 16 : 8))
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
                    colors: [
                        .black.opacity(isExtraLarge ? 0.15 : 0.0),
                        .black.opacity(isExtraLarge ? 0.75 : 0.55)
                    ],
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
        .supportedFamilies(PlayGameWidget.supportedFamilies)
    }

    private static var supportedFamilies: [WidgetFamily] {
        var families: [WidgetFamily] = [
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .systemExtraLarge
        ]
        if #available(iOSApplicationExtension 27.0, *) {
            families.append(.systemExtraLargePortrait)
        }
        return families
    }
}

// MARK: - Bundle

@main
struct GameNetWidgetBundle: WidgetBundle {
    var body: some Widget {
        PlayGameWidget()
        GameplayLiveActivity()
    }
}
