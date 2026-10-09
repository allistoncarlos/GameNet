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

    private var isExtraLargePortrait: Bool {
        if #available(iOSApplicationExtension 27.0, *) {
            return family == .systemExtraLargePortrait
        }
        return false
    }

    private var isLargeFamily: Bool {
        family == .systemLarge || isExtraLargePortrait
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
            VStack(alignment: .leading, spacing: gameInfoSpacing) {
                Spacer()

                if isLargeFamily, !game.platform.isEmpty {
                    Text(game.platform)
                        .font(platformFont)
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
            .padding(isLargeFamily ? 4 : 0)

            toggleButton(game)
        }
    }

    private var gameInfoSpacing: CGFloat {
        if isExtraLargePortrait { return 6 }
        if isLargeFamily { return 4 }
        return 2
    }

    private var gameNameLineLimit: Int {
        switch family {
        case .systemSmall: return 2
        case .systemMedium: return 1
        case .systemLarge: return 3
        default: return isExtraLargePortrait ? 5 : 1
        }
    }

    private var gameNameFont: Font {
        if isExtraLargePortrait { return .title3.weight(.semibold) }
        if family == .systemLarge { return .subheadline.weight(.semibold) }
        return .caption.weight(.semibold)
    }

    private var platformFont: Font {
        if isExtraLargePortrait { return .subheadline.weight(.medium) }
        return .caption2.weight(.medium)
    }

    private var sessionTimeFont: Font {
        if isExtraLargePortrait { return .subheadline }
        if isLargeFamily { return .caption }
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
        if isExtraLargePortrait { return 64 }
        if isLargeFamily { return 54 }
        return 46
    }

    private var toggleIconFont: Font {
        if isExtraLargePortrait { return .title }
        if isLargeFamily { return .title2 }
        return .title3
    }

    private func messageView(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: isLargeFamily ? 10 : 6) {
            Image(systemName: icon)
                .font(isExtraLargePortrait ? .largeTitle : (isLargeFamily ? .title : .title2))
            Text(title)
                .font(isExtraLargePortrait ? .headline.weight(.semibold) : .caption.weight(.semibold))
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(isLargeFamily ? .subheadline : .caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(isLargeFamily ? 16 : 8)
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
        .supportedFamilies(PlayGameWidget.supportedFamilies)
    }

    private static var supportedFamilies: [WidgetFamily] {
        var families: [WidgetFamily] = [.systemSmall, .systemMedium, .systemLarge]
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
