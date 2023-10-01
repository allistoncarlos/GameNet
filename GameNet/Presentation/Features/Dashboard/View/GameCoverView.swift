//
//  GameCoverView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 01/10/23.
//

import SwiftUI
import CachedAsyncImage
import GameNet_Network

struct GameCoverView: View {
    var playingGame: PlayingGame
    
    var body: some View {
        NavigationLink(value: playingGame) {
            VStack(alignment: .leading) {
                CachedAsyncImage(url: URL(string: playingGame.coverURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: { ProgressView().progressViewStyle(.circular) }
                
                Text(playingGame.name)
                    .font(.dashboardGameTitle)
                    .multilineTextAlignment(.leading)
                Text(playingGame.latestGameplaySession?.start.toFormattedString() ?? "")
                    .font(.dashboardGameSubtitle)
                    .multilineTextAlignment(.leading)
            }
        }
        .containerRelativeFrame(.vertical)
        .containerRelativeFrame(.horizontal)
        .scrollTransition(axis: .horizontal) { content, phase in
            content
                .scaleEffect(
                    x: phase.isIdentity ? 1 : 0.8,
                    y: phase.isIdentity ? 1 : 0.8
                )
        }
    }
}

#Preview {
    GameCoverView(playingGame: .init(
        id: "1",
        name: "The Legend of Zelda: Tears of the Kingdom",
        platform: "Nintendo Switch",
        coverURL: "https://placehold.co/400",
        latestGameplaySession: nil
    ))
}
