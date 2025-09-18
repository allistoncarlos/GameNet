//
//  GameDetailView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 24/01/23.
//

import CachedAsyncImage
import GameNet_Network
import SwiftUI
import TTProgressHUD
import UniformTypeIdentifiers

// MARK: - GameDetailView

struct GameDetailView: View {
    @StateObject var viewModel: GameDetailViewModel

    @Binding var navigationPath: NavigationPath

    @State var isLoading = true
    @State var isCopied = false
    @State var showingConfirmation = false
    @State var buttonImage = "play.fill"
    @State var confirmText = "iniciar"

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                if let game = viewModel.game {
                    ZStack(alignment: .bottomTrailing) {
                        CachedAsyncImage(url: URL(string: game.cover)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: { ProgressView().progressViewStyle(.circular) }
                            .frame(height: 250)
                            .onTapGesture(count: 2) {
                                #if os(iOS)
                                if let gameId = game.id {
                                    UIPasteboard.general.setValue(
                                        gameId,
                                        forPasteboardType: UTType.plainText.identifier
                                    )
                                    
                                    isCopied = true
                                }
                                #endif
                            }
                        
                        if FirebaseRemoteConfig.toggleGameplaySession {
                            Button {
                                showingConfirmation = true
                            } label: {
                                Image(systemName: buttonImage)
                                    .frame(width: 40, height: 40)
                            }
                            .offset(x: -5, y: -5)
                            .buttonBorderShape(.circle)
                            .buttonStyle(.glassProminent)
                            .tint(Color.main.opacity(0.4))
                            .confirmationDialog("", isPresented: $showingConfirmation) {
                                Button("Confirmar") {
                                    Task {
                                        await viewModel.save()
                                    }
                                }
                            } message: {
                                Text("Deseja \(confirmText) o jogo \(game.name)?")
                            }
                        }
                    }

                    Text(game.name)
                        .font(.system(.title))
                        .bold()
                        .multilineTextAlignment(.center)

                    Text(game.platform)
                        .font(.system(.title2))
                        .bold()
                        .multilineTextAlignment(.center)

                    VStack(spacing: 2) {
                        Text("Preço: \(game.value.toCurrencyString() ?? "0,00")")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 16))

                        if let boughtDate = game.boughtDate {
                            Text("Comprado em \(boughtDate.toFormattedString())")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 16))
                        }

                        if let latestGameplays = game.gameplays?.last {
                            if let finish = latestGameplays.finish {
                                Text("Finalizado em \(finish.toFormattedString())")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: 16))
                            } else {
                                Text("Jogando desde: \(latestGameplays.start.toFormattedString())")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: 16))
                            }
                        }
                    }

                    if let gameplays = viewModel.gameplays {
                        Text("Gameplays Recentes")
                            .font(.system(.title3))
                            .bold()
                            .multilineTextAlignment(.center)

                        VStack(spacing: 2) {
                            Text("Total de \(gameplays.totalGameplayTime) horas")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 16))
                                .bold()
                            Text("Média de \(gameplays.averageGameplayTime) horas")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 16))
                                .bold()
                        }

                        VStack(spacing: 5) {
                            ForEach(
                                gameplays.sessions.sorted(by: { $0!.start >= $1!.start }),
                                id: \.?.id
                            ) { session in
                                if let session {
                                    if let finishSession = session.finish {
                                        VStack(spacing: 2) {
                                            Text("\(session.start.toFormattedString(dateFormat: GameNetApp.dateTimeFormat)) até \(finishSession.toFormattedString(dateFormat: GameNetApp.dateTimeFormat))")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .font(.system(size: 14))

                                            Text("Total de \(session.totalGameplayTime)")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .font(.system(size: 14))
                                        }
                                    } else {
                                        Text("Jogando desde \(session.start.toFormattedString(dateFormat: GameNetApp.dateTimeFormat))")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .font(.system(size: 16))
                                            .bold()
                                            .padding(.bottom, 10)
                                    }
                                }
                            }
                        }
                    }

                    Spacer()
                }
            }
            .padding(10)
        }
        .disabled(isLoading)
        .overlay(
            TTProgressHUD($isCopied, config: TTProgressHUDConfig(
                type: .success,
                title: "Copiado",
                shouldAutoHide: true,
                allowsTapToHide: true,
                autoHideInterval: 3.0
            ))
        )
        .navigationView(title: viewModel.game?.name ?? "")
        .overlay(
            TTProgressHUD($isLoading, config: GameNetApp.hudConfig)
        )
        .onChange(of: viewModel.state) { _, state in
            isLoading = state == .loading
        }
        .onChange(of: viewModel.isStarted) { oldValue, newValue in
            self.buttonImage = newValue ? "stop.fill" : "play.fill"
            self.confirmText = newValue ? "finalizar" : "iniciar"
        }
        .task {
            await viewModel.fetchData()
        }
    }
}

// MARK: - Previews

#Preview("Dark Mode") {
    let _ = RepositoryContainer.gameRepository.register(factory: { MockGameRepository() })

    GameDetailView(
        viewModel: GameDetailViewModel(gameId: "1"),
        navigationPath: .constant(NavigationPath())
    ).preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    let _ = RepositoryContainer.gameRepository.register(factory: { MockGameRepository() })

    GameDetailView(
        viewModel: GameDetailViewModel(gameId: "1"),
        navigationPath: .constant(NavigationPath())
    ).preferredColorScheme(.light)
}
