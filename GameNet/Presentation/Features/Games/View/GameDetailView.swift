//
//  GameDetailView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 24/01/23.
//

import GameNet_Network
import SwiftUI

// MARK: - GameDetailView

struct GameDetailView: View {
    @StateObject var viewModel: GameDetailViewModel
    @Binding var navigationPath: NavigationPath

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                if let game = viewModel.game {
                    AsyncImage(url: URL(string: game.cover)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: { ProgressView().progressViewStyle(.circular) }
                        .frame(height: 250)

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

                        if let sessions = gameplays.sessions {
                            VStack(spacing: 5) {
                                ForEach(sessions, id: \.?.id) { session in
                                    if let session {
                                        if let finishSession = session.finish {
                                            VStack(spacing: 2) {
                                                Text("\(session.start.toFormattedString(dateFormat: GameNetApp.dateFormat)) até \(finishSession.toFormattedString(dateFormat: GameNetApp.dateFormat))")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(.system(size: 14))

                                                Text("Total de \(session.totalGameplayTime)")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(.system(size: 14))
                                            }
                                        } else {
                                            Text("Jogando desde \(session.start.toFormattedString())")
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .font(.system(size: 14))
                                        }
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
