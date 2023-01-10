//
//  DashboardView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import Factory
import SwiftUI

// MARK: - DashboardView

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    if viewModel.uiState == .loading {
                        ProgressView()
                    } else {
                        VStack(spacing: -20) {
                            if viewModel.dashboard?.playingGames != nil {
                                playingCard
                            }

                            if viewModel.dashboard?.totalGames != nil {
                                physicalDigitalCard
                            }

                            if viewModel.dashboard?.finishedByYear != nil {
                                finishedByYearCard
                            }

                            if viewModel.dashboard?.boughtByYear != nil {
                                boughtByYearCard
                            }

                            if viewModel.dashboard?.gamesByPlatform != nil {
                                gamesByPlatformCard
                            }
                        }
                    }
                }
                .navigationView(title: "Dashboard")
            }
        }.task {
            await viewModel.fetchData()
        }
    }
}

extension DashboardView {
    var playingCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.primaryCardBackground)

            VStack(alignment: .leading, spacing: 15) {
                VStack {
                    Text("Jogando")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                        .font(.cardTitle)
                }

                if let playingGames = viewModel.dashboard?.playingGames {
                    ForEach(playingGames, id: \.id) { playingGame in
                        VStack(alignment: .leading) {
                            Text(playingGame.name)
                                .font(.dashboardGameTitle)
                            Text(playingGame.latestGameplaySession?.start.toFormattedString() ?? "")
                                .font(.dashboardGameSubtitle)
                        }
                    }
                }
            }
            .padding()
        }
        .padding()
    }
}

extension DashboardView {
    var physicalDigitalCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.secondaryCardBackground)

            VStack(alignment: .leading, spacing: 5) {
                VStack {
                    if let totalGames = viewModel.dashboard?.totalGames {
                        Text("\(totalGames) Jogos")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                            .font(.cardTitle)
                    }
                }

                if let formattedTotalPrice = viewModel.dashboard?.totalPrice?.toCurrencyString() {
                    Text(formattedTotalPrice)
                        .font(.dashboardGameSubtitle)
                }

                VStack(alignment: .leading) {
                    if let digital = viewModel.dashboard?.physicalDigital?.digital, let physical = viewModel.dashboard?.physicalDigital?.physical {
                        Text("\(digital) Digitais")
                            .font(.dashboardGameTitle)
                        Text("\(physical) Físicos")
                            .font(.dashboardGameTitle)
                    }
                }
            }
            .padding()
        }
        .padding()
    }
}

extension DashboardView {
    var finishedByYearCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.tertiaryCardBackground)

            VStack(alignment: .leading, spacing: 15) {
                VStack {
                    Text("Finalizados por Ano")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                        .font(.cardTitle)
                }

                VStack(alignment: .leading) {
                    if let finishedGamesByYear = viewModel.dashboard?.finishedByYear {
                        ForEach(finishedGamesByYear, id: \.year) { finishedGame in
                            HStack(spacing: 20) {
                                Text(finishedGame.total.toLeadingZerosString(decimalPlaces: 2))
                                    .font(.dashboardGameTitle)
                                Text(String(finishedGame.year))
                                    .font(.dashboardGameTitle)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .padding()
    }
}

extension DashboardView {
    var boughtByYearCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.tertiaryCardBackground)

            VStack(alignment: .leading, spacing: 15) {
                VStack {
                    Text("Comprados por Ano")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                        .font(.cardTitle)
                }

                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        if let boughtByYear = viewModel.dashboard?.boughtByYear {
                            ForEach(boughtByYear, id: \.year) { boughtGame in
                                HStack(spacing: 20) {
                                    if let boughtGameQuantity = boughtGame.quantity.toLeadingZerosString(decimalPlaces: 2) {
                                        Text(boughtGameQuantity)
                                            .font(.dashboardGameTitle)
                                    }

                                    Text(String(boughtGame.year))
                                        .font(.dashboardGameTitle)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .padding()
    }
}

extension DashboardView {
    var gamesByPlatformCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.tertiaryCardBackground)

            VStack(alignment: .leading, spacing: 15) {
                VStack {
                    Text("Jogos por Plataforma")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                        .font(.cardTitle)
                }

                VStack(alignment: .leading, spacing: 5) {
                    if let gamesByPlatform = viewModel.dashboard?.gamesByPlatform?.platforms {
                        ForEach(gamesByPlatform, id: \.id) { gameByPlatform in
                            HStack(spacing: 20) {
                                Text(gameByPlatform.platformGamesTotal.toLeadingZerosString(decimalPlaces: 3))
                                    .font(.dashboardGameTitle)
                                Text(gameByPlatform.name)
                                    .font(.dashboardGameTitle)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .padding()
    }
}

// MARK: - DashboardView_Previews

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let _ = RepositoryContainer.dashboardRepository.register(factory: { MockDashboardRepository() })

        ForEach(ColorScheme.allCases, id: \.self) {
            DashboardView(viewModel: DashboardViewModel()).preferredColorScheme($0)
        }
    }
}
