//
//  NowPlayingBanner.swift
//  GameNet
//
//  Faixa compacta do jogo com sessão em andamento.
//

import SwiftUI

struct NowPlayingBanner: View {
    let highlight: NowPlayingHighlight
    var onRefresh: () async -> Void = {}

    var body: some View {
        PlayingLibraryItem(playingGame: highlight.playingGame, onRefresh: onRefresh) { viewModel, refresh in
            banner(viewModel: viewModel, onRefresh: refresh)
        }
        .accessibilityIdentifier("now-playing-banner")
        .gameStoryShareSheet($storyContent)
    }

    // MARK: Private

    @State private var storyContent: GameStoryContent?

    private func banner(viewModel: GameCoverViewModel, onRefresh: @escaping () async -> Void) -> some View {
        HStack(spacing: 12) {
            PlayingGameCoverArtwork(
                coverURL: highlight.coverURL,
                cornerRadius: 8,
                contentMode: .fill
            )
            .frame(width: 42)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    NowPlayingPulseDot(size: 6)

                    Text("Jogando agora")
                        .font(.dashboardGameSubtitle)
                        .opacity(0.85)
                }

                Text(highlight.name)
                    .font(.listCardTitle)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }

            Spacer(minLength: 8)

            NowPlayingSessionTimer(start: highlight.absoluteStart, font: .dashboardGameSubtitle)

            Button {
                storyContent = GameStoryContent(highlight: highlight)
            } label: {
                ShareStoryLabel(size: 34)
            }
            .gameNetCircleButtonBorder()
            .gameNetGlassProminentButtonStyle(tint: Color.white.opacity(0.18))
            .accessibilityLabel("Compartilhar story")
            .accessibilityIdentifier("now-playing-share-story")

            PlayingGameSessionControls(
                viewModel: viewModel,
                onRefresh: onRefresh,
                buttonSize: 34,
                tint: .main,
                onShareStory: { storyContent = GameStoryContent(highlight: highlight) }
            )
        }
        .foregroundStyle(.white)
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .gameNetGlassEffect(
            .tinted(Color.primaryCardBackground),
            in: .rect(cornerRadius: 18)
        )
        .shadow(color: .black.opacity(0.22), radius: 10, y: 4)
    }
}
