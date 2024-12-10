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
    @ObservedObject var viewModel: GameCoverViewModel
    @State private var showingConfirmation = false
    
    @State var buttonImage = "play.fill"
    @State var confirmText = "iniciar"
    
    var body: some View {
        SwiftUI.NavigationLink(value: viewModel.playingGame) {
            VStack(alignment: .center) {
                ZStack(alignment: .bottomTrailing) {
                    
                CachedAsyncImage(url: URL(string: viewModel.playingGame.coverURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: { ProgressView().progressViewStyle(.circular) }
                    if FirebaseRemoteConfig.toggleGameplaySession {
                        Button(action: {
                            showingConfirmation = true
                        }, label: {
                            Image(systemName: buttonImage)
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        })
                        .foregroundStyle(Color.white)
                        .background {
                            Circle()
                                .fill(Color.main)
                                .shadow(color: .white, radius: 4, x: -2, y: 1)
                        }
                        .offset(x: -5, y: -5)
                        .confirmationDialog("", isPresented: $showingConfirmation) {
                            Button("Confirmar") {
                                Task {
                                    await viewModel.save()
                                }
                            }
                            Button("Cancelar", role: .cancel) { }
                        } message: {
                            Text("Deseja \(confirmText) o jogo \(viewModel.playingGame.name)?")
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
