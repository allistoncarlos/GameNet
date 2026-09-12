//
//  NowPlayingBanner.swift
//  GameNet
//
//  Destaque em faixa compacta do jogo com sessão em andamento.
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
    }

    // MARK: Private

    private func banner(viewModel: GameCoverViewModel, onRefresh: @escaping () async -> Void) -> some View {
        HStack(spacing: 12) {
            cover

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

            PlayingGameSessionControls(
                viewModel: viewModel,
                onRefresh: onRefresh,
                buttonSize: 34,
                tint: .main
            )
        }
        .foregroundStyle(.white)
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .gameNetGlassEffect(
            .tinted(Color.primaryCardBackground),
            in: .rect(cornerRadius: 18)
        )
        .dashboardOuterPadding()
    }

    @ViewBuilder
    private var cover: some View {
        if highlight.playingGame.id != nil {
            NavigationLink(value: highlight.playingGame) {
                coverArtwork
            }
            .buttonStyle(.plain)
        } else {
            coverArtwork
        }
    }

    private var coverArtwork: some View {
        PlayingGameCoverArtwork(
            coverURL: highlight.coverURL,
            cornerRadius: 8,
            contentMode: .fill
        )
        .frame(width: 42)
    }
}
