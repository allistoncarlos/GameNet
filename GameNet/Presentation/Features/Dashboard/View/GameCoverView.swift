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
    var isStarted: Bool {
        if let latestGameplaySession = playingGame.latestGameplaySession {
            return latestGameplaySession.finish == nil
        }
        
        return false
    }
    
    @State private var showingConfirmation = false
    
    var body: some View {
        NavigationLink(value: playingGame) {
            VStack(alignment: .center) {
                CachedAsyncImage(url: URL(string: playingGame.coverURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: { ProgressView().progressViewStyle(.circular) }
                
                if FirebaseRemoteConfig.toggleGameplaySession {
                    Button(isStarted ? "Finalizar" : "Iniciar") {
                        showingConfirmation = true
                    }
                    .buttonStyle(ActionButtonStyle())
                    .confirmationDialog("", isPresented: $showingConfirmation) {
                        Button("Confirmar") {
                            // TODO: Fazer o toggle aqui
                        }
                        Button("Cancelar", role: .cancel) { }
                    } message: {
                        Text("Deseja " + (isStarted ? "finalizar" : "iniciar") + " o jogo \(playingGame.name)?")
                    }
                }
                
                Text(playingGame.name)
                    .font(.dashboardGameTitle)
                    .multilineTextAlignment(.center)
                Text(playingGame.latestGameplaySession?.start.toFormattedString() ?? "")
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
