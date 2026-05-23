//
//  PlayingGamesView.swift
//  GameNet.Watch Watch App
//
//  Created by Alliston Aleixo on 06/01/23.
//

import SwiftUI

struct PlayingGamesView: View {
    @ObservedObject var viewModel: PlayingGamesViewModel

    var body: some View {
        Group {
            switch viewModel.uiState {
            case .loading:
                ProgressView()
            case .notLogged:
                notLoggedContent
            case .empty:
                emptyContent
            case .error(let message):
                errorContent(message)
            case .content:
                carouselContent
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private var carouselContent: some View {
        VStack(spacing: 8) {
            TabView(selection: $viewModel.selectedGameIndex) {
                ForEach(Array(viewModel.games.enumerated()), id: \.element.id) { index, game in
                    gameCard(game)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 130)

            pageIndicator
        }
    }

    private func gameCard(_ game: WatchPlayingGame) -> some View {
        VStack(spacing: 6) {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: game.coverURL)) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.gray.opacity(0.25))
                            .overlay {
                                ProgressView()
                            }
                    }
                }
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                Button {
                    Task { await viewModel.toggleGameplay() }
                } label: {
                    Image(systemName: game.isStarted ? "stop.fill" : "play.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(Color.gameNetMain)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isSaving)
                .offset(x: 4, y: 4)
            }

            Text(game.name)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(viewModel.games.indices, id: \.self) { index in
                Circle()
                    .fill(index == viewModel.selectedGameIndex ? Color.gameNetMain : Color.gray.opacity(0.4))
                    .frame(width: 6, height: 6)
            }
        }
    }

    private var notLoggedContent: some View {
        VStack(spacing: 8) {
            Text("Login necessário")
                .font(.headline)
            Text("Abra o GameNet no iPhone e faça login.")
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
    }

    private var emptyContent: some View {
        VStack(spacing: 8) {
            Text("Nenhum jogo em andamento")
                .font(.headline)
            Text("Adicione jogos na seção Jogando do iPhone.")
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
    }

    private func errorContent(_ message: String) -> some View {
        VStack(spacing: 8) {
            Text("Não foi possível carregar")
                .font(.headline)
            Text(message)
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    PlayingGamesView(viewModel: PlayingGamesViewModel())
}
