//
//  DashboardView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import Factory
import GameNet_Network
import SwiftUI
import TTProgressHUD
import CachedAsyncImage

// MARK: - DashboardView

struct DashboardView: View {

    // MARK: Internal

    @ObservedObject var viewModel: DashboardViewModel
    @State var isLoading = true

    var body: some View {
        NavigationStack(path: $presentedViews) {
            ScrollView {
                VStack(spacing: -20) {
                    if FirebaseRemoteConfig.dashboardViewCarousel {
                        if viewModel.dashboard?.playingGames != nil {
                            playingCard
                        }
                    }

                    if viewModel.gameplaySessions != nil {
                        gameplaySessions
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
            .disabled(isLoading)
            .navigationView(title: "Dashboard")
            .navigationDestination(for: FinishedGameByYearTotal.self) { finishedGame in
                viewModel.showFinishedGamesView(
                    navigationPath: $presentedViews,
                    year: finishedGame.year
                )
            }
            .navigationDestination(for: BoughtGamesByYearTotal.self) { boughtGame in
                viewModel.showBoughtGamesView(
                    navigationPath: $presentedViews,
                    year: boughtGame.year
                )
            }
            .navigationDestination(for: PlayingGame.self) { playingGame in
                if let gameId = playingGame.id {
                    viewModel.showGameDetailView(
                        navigationPath: $presentedViews,
                        id: gameId
                    )
                }
            }
            .navigationDestination(for: ListItem.self) { game in
                if let gameId = game.userGameId {
                    viewModel.showGameDetailView(
                        navigationPath: $presentedViews,
                        id: gameId
                    )
                }
            }
            .navigationDestination(for: GameplaySessionNavigation.self) { gameplaySessionNavigation in
                viewModel.showGameplaySessionDetailView(
                    navigationPath: $presentedViews,
                    gameplaySession: gameplaySessionNavigation
                )
            }
            .navigationDestination(for: GameplaySession.self) { gameplaySession in
                viewModel.showGameDetailView(
                    navigationPath: $presentedViews,
                    id: gameplaySession.userGameId
                )
            }
            .navigationDestination(for: String.self) { platformId in
                #if os(iOS) && DEBUG
                viewModel.featureToggle()
                #endif
            }
            .toolbar {
                #if os(iOS) && DEBUG
                Button(action: {}) {
                    NavigationLink(value: String()) {
                        Image(systemName: "gear")
                    }
                }
                #endif
            }
        }
        .overlay(
            TTProgressHUD($isLoading, config: GameNetApp.hudConfig)
        )
        .onChange(of: viewModel.state) { state in
            isLoading = state == .loading
        }
        .task {
            await viewModel.fetchData()
        }
    }

    // MARK: Private

    @State private var presentedViews = NavigationPath()
    var containerHeight: CGFloat = UIScreen.main.bounds.height
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
                
                ScrollView(.horizontal) {
                    VStack(alignment: .leading, spacing: 15) {
                        LazyHStack {
                            if let playingGames = viewModel.dashboard?.playingGames {
                                let ordered = playingGames.sorted(by: { lhs, rhs in
                                    if let lhsDate = lhs.latestGameplaySession?.finish,
                                       let rhsDate = rhs.latestGameplaySession?.finish {
                                        
                                        return lhsDate > rhsDate
                                    }
                                    
                                    return true
                                })
                                
                                ForEach(ordered, id: \.id) { playingGame in
                                    GameCoverView(playingGame: playingGame)
                                }
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .padding()
        }
        .frame(height: containerHeight * 0.5)
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
                        Group {
                            ForEach(finishedGamesByYear, id: \.year) { finishedGame in
                                NavigationLink(value: finishedGame) {
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
                                NavigationLink(value: boughtGame) {
                                    HStack(spacing: 20) {
                                        Text(
                                            boughtGame.quantity
                                                .toLeadingZerosString(decimalPlaces: 2)
                                        )
                                        .font(.dashboardGameTitle)

                                        Text(String(boughtGame.year))
                                            .font(.dashboardGameTitle)

                                        Spacer()
                                        
                                        if let formattedTotalPrice = boughtGame.total.toCurrencyString() {
                                            Text(String("\(formattedTotalPrice)"))
                                                .font(.dashboardGameTitle)
                                        }
                                    }
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

extension DashboardView {
    var gameplaySessions: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.secondaryCardBackground)

            VStack(alignment: .leading, spacing: 15) {
                VStack {
                    Text("Horas Jogadas por Ano")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                        .font(.cardTitle)
                }

                VStack(alignment: .leading, spacing: 5) {
                    if let gameplaySessions = viewModel.gameplaySessions {
                        ForEach(gameplaySessions.sorted(by: { $0.key >= $1.key }), id: \.key) { key, gameplaySession in
                            NavigationLink(value: GameplaySessionNavigation(key: key, value: gameplaySession)) {
                                HStack(spacing: 20) {
                                    Text(String(key))
                                        .font(.dashboardGameTitle)
                                    Text(gameplaySession.totalGameplayTime)
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

// MARK: - DashboardView_Previews

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let _ = RepositoryContainer.dashboardRepository.register(factory: { MockDashboardRepository() })

        ForEach(ColorScheme.allCases, id: \.self) {
            DashboardView(viewModel: DashboardViewModel()).preferredColorScheme($0)
        }
    }
}
