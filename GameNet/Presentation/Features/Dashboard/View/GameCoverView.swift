//
//  GameCoverView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 01/10/23.
//

import SwiftUI
import CachedAsyncImage

private enum GameCoverAction: Identifiable {
    case toggle
    case finishGame
    case dropGameplay

    var id: Int {
        switch self {
        case .toggle: return 0
        case .finishGame: return 1
        case .dropGameplay: return 2
        }
    }
}

struct GameCoverView: View {
    @ObservedObject var viewModel: GameCoverViewModel
    var onRefresh: () async -> Void = {}
    @State private var activeAction: GameCoverAction?
    @State private var coverAccentColor = Color.main
    
    @State var buttonImage = "play.fill"
    @State var confirmText = "iniciar"
    
    private var coverURL: String {
        viewModel.playingGame.coverURL
    }
    
    var body: some View {
        SwiftUI.NavigationLink(value: viewModel.playingGame) {
            VStack(alignment: .center) {
                ZStack(alignment: .bottomTrailing) {
                    
                CachedAsyncImage(url: URL(string: coverURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    default:
                        coverImageSkeleton
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .gameCoverTransitionSource(id: viewModel.playingGame.id)
                    if FirebaseRemoteConfig.toggleGameplaySession {
                        Button {
                            activeAction = .toggle
                        } label: {
                            Image(systemName: buttonImage)
                                .frame(width: 40, height: 40)
                        }
                        .offset(x: -5, y: -5)
                        .buttonBorderShape(.circle)
                        .buttonStyle(.glassProminent)
                        .tint(coverAccentColor.opacity(0.5))
                        .animation(.smooth, value: coverAccentColor)
                        .contextMenu {
                            Button {
                                activeAction = .finishGame
                            } label: {
                                Label("Zerei o Jogo", systemImage: "checkmark.seal.fill")
                            }

                            Button(role: .destructive) {
                                activeAction = .dropGameplay
                            } label: {
                                Label("Parar de Jogar", systemImage: "xmark.circle.fill")
                            }
                        }
                        .confirmationDialog(
                            "",
                            isPresented: Binding(
                                get: { activeAction != nil },
                                set: { isPresented in
                                    if !isPresented { activeAction = nil }
                                }
                            ),
                            presenting: activeAction
                        ) { action in
                            switch action {
                            case .toggle:
                                Button("Confirmar") {
                                    Task {
                                        if await viewModel.save() {
                                            await onRefresh()
                                        }
                                    }
                                }
                            case .finishGame:
                                Button("Zerei o Jogo") {
                                    Task {
                                        if await viewModel.finishGame() {
                                            await onRefresh()
                                        }
                                    }
                                }
                            case .dropGameplay:
                                Button("Parar de Jogar", role: .destructive) {
                                    Task {
                                        if await viewModel.dropGameplay() {
                                            await onRefresh()
                                        }
                                    }
                                }
                            }
                        } message: { action in
                            switch action {
                            case .toggle:
                                Text("Deseja \(confirmText) o jogo \(viewModel.playingGame.name)?")
                            case .finishGame:
                                Text("Deseja marcar o jogo \(viewModel.playingGame.name) como zerado?")
                            case .dropGameplay:
                                Text("Deseja parar de jogar o jogo \(viewModel.playingGame.name)?")
                            }
                        }
                    }
                }
                
                Text(viewModel.playingGame.name)
                    .font(.dashboardGameTitle)
                    .multilineTextAlignment(.center)
                Text(viewModel.playingGame.latestGameplaySession?.start.toFormattedString() ?? "")
                    .font(.dashboardGameSubtitle)
                    .multilineTextAlignment(.center)
            }
        }
        .containerRelativeFrame(.horizontal)
        .scrollTransition(axis: .horizontal) { content, phase in
            content
                .scaleEffect(
                    x: phase.isIdentity ? 1 : 0.8,
                    y: phase.isIdentity ? 1 : 0.8
                )
        }
        .onChange(of: viewModel.isStarted) { oldValue, newValue in
            self.buttonImage = newValue ? "stop.fill" : "play.fill"
            self.confirmText = newValue ? "finalizar" : "iniciar"
        }
        .task(id: coverURL) {
            guard !coverURL.isEmpty else { return }
            #if os(iOS)
            coverAccentColor = await CoverAccentColor.from(urlString: coverURL)
            #endif
        }
    }

    private var coverImageSkeleton: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.secondary.opacity(0.2))
            .aspectRatio(2 / 3, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .redacted(reason: .placeholder)
    }
}

#Preview {
    GameCoverView(
        viewModel: GameCoverViewModel(playingGame: .init(
            id: "1",
            name: "The Legend of Zelda: Tears of the Kingdom",
            platform: "Nintendo Switch",
            coverURL: "https://placehold.co/400",
            latestGameplaySession: nil)
        )
    )
}
