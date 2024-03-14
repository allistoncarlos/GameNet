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

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                if let game = viewModel.game {
                    CachedAsyncImage(url: URL(string: game.cover)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: { ProgressView().progressViewStyle(.circular) }
                        .frame(height: 250)
                    // TODO: tvOS
//                        .onTapGesture(count: 2) {
//                            if let gameId = game.id {
//                                UIPasteboard.general.setValue(
//                                    gameId,
//                                    forPasteboardType: UTType.plainText.identifier
//                                )
//
//                                isCopied = true
//                            }
//                        }

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
        .task {
            await viewModel.fetchData()
        }
    }
}

// MARK: - GameDetailView_Previews

struct GameDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let _ = RepositoryContainer.gameRepository.register(factory: { MockGameRepository() })

        if let game = MockGameRepository().fetchData(id: "1"), let gameId = game.id {
            GameDetailView(
                viewModel: GameDetailViewModel(gameId: gameId),
                navigationPath: .constant(NavigationPath())
            )
        } else {
            EmptyView()
        }
    }
}
