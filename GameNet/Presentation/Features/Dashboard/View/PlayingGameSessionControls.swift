//
//  PlayingGameSessionControls.swift
//  GameNet
//

import SwiftUI

enum GameCoverAction: Identifiable {
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

struct PlayingGameSessionControls: View {
    @ObservedObject var viewModel: GameCoverViewModel
    var onRefresh: () async -> Void = {}
    var buttonSize: CGFloat = 40
    var tint: Color = .main

    @State private var activeAction: GameCoverAction?
    @State private var buttonImage = "play.fill"
    @State private var confirmText = "iniciar"

    var body: some View {
        Button {
            activeAction = .toggle
        } label: {
            Image(systemName: buttonImage)
                .frame(width: buttonSize, height: buttonSize)
        }
        .gameNetCircleButtonBorder()
        .gameNetGlassProminentButtonStyle(tint: tint.opacity(0.5))
        .animation(.gameNetSmooth, value: tint)
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
        .onAppear(perform: syncButtonState)
        .onChangeCompat(of: viewModel.isStarted) { _ in
            syncButtonState()
        }
    }

    private func syncButtonState() {
        buttonImage = viewModel.isStarted ? "stop.fill" : "play.fill"
        confirmText = viewModel.isStarted ? "finalizar" : "iniciar"
    }
}
