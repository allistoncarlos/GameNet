//
//  PlayingGamesView.swift
//  GameNet.Watch Watch App
//
//  Created by Alliston Aleixo on 06/01/23.
//

import SwiftUI
import WatchKit
#if canImport(UIKit)
import UIKit
#endif

struct PlayingGamesView: View {
    @ObservedObject var viewModel: PlayingGamesViewModel
    @ObservedObject private var connectivity = WatchConnectivityManager.shared

    /// Proporção estilo Apple Music: capa ocupa ~70% da largura da tela.
    private var artworkSize: CGFloat {
        let width = WKInterfaceDevice.current().screenBounds.width
        let height = WKInterfaceDevice.current().screenBounds.height
        
        let ratio = 0.70
        
        return min(width * ratio, height * ratio)
    }

    var body: some View {
        Group {
            switch viewModel.uiState {
            case .loading:
                ProgressView()
            case .notLogged:
                statusView(
                    title: "Login necessário",
                    subtitle: "Abra o GameNet no iPhone e faça login."
                )
            case .empty:
                statusView(
                    title: "Nenhum jogo em andamento",
                    subtitle: "Adicione jogos na seção Jogando do iPhone."
                )
            case .error(let message):
                statusView(
                    title: "Não foi possível carregar",
                    subtitle: message
                )
            case .content:
                carouselContent
            }
        }
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Carrossel

    private var carouselContent: some View {
        VStack {
            TabView(selection: $viewModel.selectedGameIndex) {
                ForEach(Array(viewModel.games.enumerated()), id: \.element.id) { index, game in
                    gamePage(game)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            if viewModel.games.count > 1 {
                pageIndicator
            }
        }
    }

    private func gamePage(_ game: WatchPlayingGame) -> some View {
            artworkStack(for: game)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func artworkStack(for game: WatchPlayingGame) -> some View {
        ZStack(alignment: .bottomTrailing) {
            gameCoverImage(for: game)
            gameplayButton(for: game)
                .padding(6)
        }
        .frame(width: artworkSize, height: artworkSize)
    }

    @ViewBuilder
    private func gameCoverImage(for game: WatchPlayingGame) -> some View {
        if let data = connectivity.coverImageData(for: game.id),
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: artworkSize, height: artworkSize)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .id(connectivity.coverRevision)
        } else {
            coverPlaceholder
                .frame(width: artworkSize, height: artworkSize)
        }
    }

    private var coverPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(Color.gray.opacity(0.22))
            .overlay {
                Image(systemName: "gamecontroller.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
    }

    private func gameplayButton(for game: WatchPlayingGame) -> some View {
        Button {
            Task { await viewModel.toggleGameplay() }
        } label: {
            Image(systemName: game.isStarted ? "stop.fill" : "play.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Color.gameNetMain)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.35), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isSaving)
    }

    private var pageIndicator: some View {
        HStack(spacing: 5) {
            ForEach(viewModel.games.indices, id: \.self) { index in
                Circle()
                    .fill(
                        index == viewModel.selectedGameIndex
                            ? Color.gameNetMain
                            : Color.gray.opacity(0.35)
                    )
                    .frame(width: 5, height: 5)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.selectedGameIndex)
    }

    // MARK: - Status

    private func statusView(title: String, subtitle: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
    }
}

#Preview {
    PlayingGamesView(viewModel: PlayingGamesViewModel())
}
