//
//  CarouselCover.swift
//  GameNet
//
//  Created by Alliston Aleixo on 11/12/24.
//

import SwiftUI

struct CarouselCover: View {
    var properties: Properties
    
    @State private var showingConfirmation = false
    @State var isStarted: Bool = false
    
    @State var buttonImage = "play.fill"
    @State var confirmText = "iniciar"
    
    var body: some View {
        if let id = properties.id,
           let url = properties.url,
           let title = properties.title,
           let subtitle = properties.value {
            SwiftUI.NavigationLink(value: id) {
                VStack(alignment: .center) {
                    ZStack(alignment: .bottomTrailing) {
                        AsyncImage(url: url)
                        
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
                                    //                                await viewModel.save()
                                }
                            }
                            Button("Cancelar", role: .cancel) { }
                        } message: {
                            Text("Deseja \(confirmText) o jogo \(title)?")
                        }
                    }
                    
                    //                Text(model.title)
                    //                    .font(.dashboardGameTitle)
                    //                    .multilineTextAlignment(.center)
                    DashboardText(title)
                    //                Text(viewModel.playingGame.latestGameplaySession?.start.toFormattedString() ?? "")
                    //                    .font(.dashboardGameSubtitle)
                    //                    .multilineTextAlignment(.center)
                    Subtitle(subtitle)
                }
            }
//            .containerRelativeFrame(.horizontal)
            .scrollTransition(axis: .horizontal) { content, phase in
                content
                    .scaleEffect(
                        x: phase.isIdentity ? 1 : 0.8,
                        y: phase.isIdentity ? 1 : 0.8
                    )
            }
            .onChange(of: isStarted) { oldValue, newValue in
                self.buttonImage = newValue ? "stop.fill" : "play.fill"
                self.confirmText = newValue ? "finalizar" : "iniciar"
            }
        }
    }
}

#Preview {
    CarouselCover(
        properties: .init(
            id: "2",
            title: "The Legend of Zelda: Breath of the Wild",
            value: "01/01/2024 10:00",
            url: "https://assets.reedpopcdn.com/148430785862.jpg/BROK/resize/1920x1920%3E/format/jpg/quality/80/148430785862.jpg"
        )
    )
}
