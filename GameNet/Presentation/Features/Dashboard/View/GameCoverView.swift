//
//  GameCoverView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 01/10/23.
//

import SwiftUI

struct GameCoverView: View {
    @ObservedObject var viewModel: GameCoverViewModel
    var maxCoverWidth: CGFloat?
    var onRefresh: () async -> Void = {}
    @State private var coverAccentColor = Color.main

    private var coverURL: String {
        viewModel.playingGame.coverURL
    }

    var body: some View {
        SwiftUI.NavigationLink(value: viewModel.playingGame) {
            VStack(alignment: .center) {
                ZStack(alignment: .bottomTrailing) {
                    PlayingGameCoverArtwork(
                        coverURL: coverURL,
                        cornerRadius: 12,
                        contentMode: .fit,
                        transitionId: viewModel.playingGame.id
                    )

                    PlayingGameSessionControls(
                        viewModel: viewModel,
                        onRefresh: onRefresh,
                        buttonSize: 40,
                        tint: coverAccentColor
                    )
                    .offset(x: -5, y: -5)
                }

                Text(viewModel.playingGame.name)
                    .font(.dashboardGameTitle)
                    .multilineTextAlignment(.center)
                Text(viewModel.playingGame.latestGameplaySession?.start.toFormattedString() ?? "")
                    .font(.dashboardGameSubtitle)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: maxCoverWidth)
            .frame(maxWidth: .infinity)
        }
        .pagingCarouselItem()
        .task(id: coverURL) {
            guard !coverURL.isEmpty else { return }
            coverAccentColor = await CoverAccentColor.from(urlString: coverURL)
        }
    }
}
