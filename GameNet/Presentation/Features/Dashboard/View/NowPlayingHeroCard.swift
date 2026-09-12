//
//  NowPlayingHeroCard.swift
//  GameNet
//
//  Destaque em card do jogo com sessão em andamento.
//

import SwiftUI

struct NowPlayingHeroCard: View {
    let highlight: NowPlayingHighlight
    var compact: Bool = true
    var onRefresh: () async -> Void = {}

    var body: some View {
        PlayingLibraryItem(playingGame: highlight.playingGame, onRefresh: onRefresh) { viewModel, refresh in
            card(viewModel: viewModel, onRefresh: refresh)
        }
        .accessibilityIdentifier("now-playing-hero")
    }

    // MARK: Private

    private var coverWidth: CGFloat {
        compact ? 104 : 124
    }

    private func card(viewModel: GameCoverViewModel, onRefresh: @escaping () async -> Void) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            HStack(alignment: .top, spacing: 16) {
                cover

                VStack(alignment: .leading, spacing: 6) {
                    Text(highlight.name)
                        .font(.dashboardGameTitle)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .multilineTextAlignment(.leading)

                    if !highlight.platform.isEmpty {
                        Text(highlight.platform)
                            .font(.dashboardGameSubtitle)
                            .opacity(0.85)
                            .lineLimit(1)
                    }

                    NowPlayingSessionTimer(start: highlight.absoluteStart)
                        .padding(.top, 2)

                    Text("Desde \(highlight.startTimeLabel)")
                        .font(.dashboardGameSubtitle)
                        .opacity(0.75)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                PlayingGameSessionControls(
                    viewModel: viewModel,
                    onRefresh: onRefresh,
                    buttonSize: compact ? 44 : 48,
                    tint: .main
                )
            }
        }
        .foregroundStyle(.white)
        .padding(20)
        .gameNetGlassEffect(
            .tinted(Color.primaryCardBackground),
            in: .rect(cornerRadius: 20)
        )
        .dashboardOuterPadding()
    }

    private var header: some View {
        HStack(spacing: 8) {
            NowPlayingPulseDot()

            Text("Jogando agora")
                .font(.dashboardGameSubtitle)
                .textCase(.uppercase)
                .opacity(0.9)

            Spacer()
        }
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
            cornerRadius: 14,
            contentMode: .fill
        )
        .frame(width: coverWidth)
        .shadow(color: .black.opacity(0.28), radius: 10, y: 6)
    }
}
