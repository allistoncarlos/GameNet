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

    @State var isCopied = false
    @State private var isSaving = false
    @State var showingConfirmation = false
    @State var buttonImage = "play.fill"
    @State var confirmText = "iniciar"

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                heroCoverSection

                Text(displayName)
                    .font(.system(.title))
                    .bold()
                    .multilineTextAlignment(.center)

                if !displayPlatform.isEmpty {
                    Text(displayPlatform)
                        .font(.system(.title2))
                        .bold()
                        .multilineTextAlignment(.center)
                }

                if let game = viewModel.game {
                    loadedDetailsSection(for: game)
                } else {
                    loadingDetailsPlaceholder
                }

                gameplaysSection
            }
            .padding(10)
            .animation(.smooth, value: viewModel.game != nil)
        }
        .overlay(
            TTProgressHUD($isCopied, config: TTProgressHUDConfig(
                type: .success,
                title: "Copiado",
                shouldAutoHide: true,
                allowsTapToHide: true,
                autoHideInterval: 3.0
            ))
        )
        .overlay(
            TTProgressHUD($isSaving, config: GameNetApp.hudConfig)
        )
        .onChange(of: viewModel.isSaving) { _, isSaving in
            self.isSaving = isSaving
        }
        .onChange(of: viewModel.isStarted) { oldValue, newValue in
            self.buttonImage = newValue ? "stop.fill" : "play.fill"
            self.confirmText = newValue ? "finalizar" : "iniciar"
        }
        .task {
            await viewModel.fetchData()
        }
    }

    private var displayCoverURL: String {
        viewModel.game?.cover ?? viewModel.preview?.coverURL ?? ""
    }

    private var displayName: String {
        viewModel.game?.name ?? viewModel.preview?.name ?? ""
    }

    private var displayPlatform: String {
        viewModel.game?.platform ?? viewModel.preview?.platform ?? ""
    }

    private var heroCoverSection: some View {
        ZStack(alignment: .bottomTrailing) {
            CachedAsyncImage(url: URL(string: displayCoverURL)) { phase in
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
            .frame(height: 250)
            .onTapGesture(count: 2) {
                #if os(iOS)
                UIPasteboard.general.setValue(
                    viewModel.game?.id ?? viewModel.preview?.name ?? "",
                    forPasteboardType: UTType.plainText.identifier
                )

                isCopied = true
                #endif
            }

            if FirebaseRemoteConfig.toggleGameplaySession, viewModel.game != nil {
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
                    Text("Deseja \(confirmText) o jogo \(displayName)?")
                }
            }
        }
    }

    private var coverImageSkeleton: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.secondary.opacity(0.2))
            .aspectRatio(2 / 3, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .redacted(reason: .placeholder)
    }

    private var loadingDetailsPlaceholder: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.secondary.opacity(0.15))
                .frame(height: 16)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.secondary.opacity(0.15))
                .frame(height: 16)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.secondary.opacity(0.15))
                .frame(width: 180, height: 16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .redacted(reason: .placeholder)
    }

    @ViewBuilder
    private func loadedDetailsSection(for game: GameDetail) -> some View {
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
        .transition(.opacity)
    }

    @ViewBuilder
    private var gameplaysSection: some View {
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
            .transition(.opacity)
        } else if viewModel.isLoadingGameplays {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
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
