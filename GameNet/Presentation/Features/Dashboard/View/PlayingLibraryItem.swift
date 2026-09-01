//
//  PlayingLibraryItem.swift
//  GameNet
//

import SwiftUI

struct PlayingLibraryItem<Content: View>: View {
    @StateObject private var viewModel: GameCoverViewModel
    private let playingGame: PlayingGame
    private let onRefresh: () async -> Void
    private let content: (GameCoverViewModel, @escaping () async -> Void) -> Content

    init(
        playingGame: PlayingGame,
        onRefresh: @escaping () async -> Void,
        @ViewBuilder content: @escaping (GameCoverViewModel, @escaping () async -> Void) -> Content
    ) {
        self.playingGame = playingGame
        self.onRefresh = onRefresh
        self.content = content
        _viewModel = StateObject(wrappedValue: GameCoverViewModel(playingGame: playingGame))
    }

    var body: some View {
        content(viewModel, onRefresh)
            .onChangeCompat(of: playingGame) { newValue in
                viewModel.applyPlayingGame(newValue)
            }
    }
}
