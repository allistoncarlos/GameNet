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
import StepperView

// MARK: - DashboardView

struct DashboardView: View {

    // MARK: Internal

    @ObservedObject var viewModel: DashboardViewModel
    @State var isLoading = false

    var body: some View {
        NavigationStack(path: $presentedViews) {
            ScrollView {
                if FirebaseRemoteConfig.serverDrivenDashboard {
                    ServerDrivenDashboardView(viewModel: ServerDrivenDashboardViewModel())
                } else {
                    VStack(spacing: -20) {
                        if viewModel.dashboard?.playingGames != nil {
                            playingCard
                        }
                        
                        if viewModel.gameplaySessions != nil {
                            if !FirebaseRemoteConfig.stepperView {
                                gameplaySessions
                            } else {
                                gameplaySessionsStepperView
                            }
                        }
                        
                        annualGameplayProgressCard
                        
                        if viewModel.dashboard?.totalGames != nil {
                            physicalDigitalCard
                        }

                        if viewModel.dashboard?.finishedByYear != nil {
                           finishedByYearTimelineCard
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
            .refreshable {
                if !FirebaseRemoteConfig.serverDrivenDashboard {
                    Task {
                        await viewModel.fetchData()
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
                        id: gameId,
                        preview: GameDetailPreview(playingGame: playingGame)
                    )
                    .gameDetailZoomTransition(gameId: gameId)
                }
            }
            .navigationDestination(for: ListItem.self) { game in
                if let gameId = game.userGameId {
                    viewModel.showGameDetailView(
                        navigationPath: $presentedViews,
                        id: gameId,
                        preview: GameDetailPreview(listItem: game)
                    )
                    .gameDetailZoomTransition(gameId: gameId)
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
                    id: gameplaySession.userGameId,
                    preview: GameDetailPreview(gameplaySession: gameplaySession)
                )
                .gameDetailZoomTransition(gameId: gameplaySession.userGameId)
            }
            .navigationDestination(for: String.self) { value in
                #if os(iOS) && DEBUG
                if value == "" {
                    viewModel.featureToggle()
                } else if FirebaseRemoteConfig.metabaseDashboard {
                    viewModel.metabaseDashboard()
                }
                #endif
            }
            .toolbar {
                #if os(iOS) && DEBUG
                Button(action: {}) {
                    SwiftUI.NavigationLink(value: String()) {
                        Image(systemName: "gear")
                    }
                }

                Button(action: {}) {
                    SwiftUI.NavigationLink(value: "metabaseDashboard") {
                        Image(systemName: "chart.pie")
                    }
                }
                #endif
            }
        }
        .gameCoverTransitionNamespace(gameCoverTransitionNamespace)
        .overlay(
            TTProgressHUD($isLoading, config: GameNetApp.hudConfig)
        )
        .onChange(of: viewModel.state) { _, state in
            isLoading = state == .loading
        }
        .task {
            if !FirebaseRemoteConfig.serverDrivenDashboard {
                await viewModel.fetchData()
            }
        }
    }

    // MARK: Private

    @State private var presentedViews = NavigationPath()
    @State private var selectedPlayingGameId: String?
    @Namespace private var gameCoverTransitionNamespace
    var containerHeight: CGFloat = UIScreen.main.bounds.height

    private var orderedPlayingGames: [PlayingGame] {
        guard let playingGames = viewModel.dashboard?.playingGames else { return [] }

        return playingGames.sorted(by: { lhs, rhs in
            if let lhsDate = lhs.latestGameplaySession?.finish,
               let rhsDate = rhs.latestGameplaySession?.finish {
                return lhsDate > rhsDate
            }

            return true
        })
    }

    private var selectedPlayingGameIndex: Int {
        guard let selectedPlayingGameId,
              let index = orderedPlayingGames.firstIndex(where: { $0.id == selectedPlayingGameId }) else {
            return 0
        }

        return index
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
                
                VStack(spacing: 12) {
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 0) {
                            ForEach(orderedPlayingGames, id: \.id) { playingGame in
                                GameCoverView(
                                    viewModel: GameCoverViewModel(
                                        playingGame: playingGame
                                    ),
                                    onRefresh: {
                                        await viewModel.fetchData()
                                    }
                                )
                                .id(playingGame.id)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                    .scrollPosition(id: $selectedPlayingGameId)
                    .scrollIndicators(.hidden)

                    if !orderedPlayingGames.isEmpty {
                        playingGamesPageIndicator
                    }
                }
                .onAppear {
                    syncSelectedPlayingGame()
                }
                .onChange(of: viewModel.dashboard?.playingGames) { _, _ in
                    syncSelectedPlayingGame()
                }
            }
            .padding()
        }
        .frame(height: containerHeight * 0.5)
        .padding()
    }

    private var playingGamesPageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(orderedPlayingGames.indices, id: \.self) { index in
                Circle()
                    .fill(index == selectedPlayingGameIndex ? Color.main : Color.gray.opacity(0.4))
                    .frame(width: 6, height: 6)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func syncSelectedPlayingGame() {
        let games = orderedPlayingGames

        guard !games.isEmpty else {
            selectedPlayingGameId = nil
            return
        }

        if let selectedPlayingGameId,
           games.contains(where: { $0.id == selectedPlayingGameId }) {
            return
        }

        self.selectedPlayingGameId = games.first?.id
    }
}

extension DashboardView {
    var annualGameplayProgressCard: some View {
        AnnualGameplayProgressChartView(
            series: viewModel.annualGameplayProgress
        )
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
    var finishedByYearTimelineCard: some View {
        FinishedByYearTimelineView(
            finishedGamesByYear: viewModel.dashboard?.finishedByYear ?? [],
            onYearTapped: { finishedGame in
                presentedViews.append(finishedGame)
            }
        )
    }
}

extension DashboardView {
    var finishedByYearCardStepperView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.tertiaryCardBackground)

            VStack {
                VStack {
                    Text("Finalizados por Ano")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                        .font(.cardTitle)
                        .padding([.top, .horizontal])
                }

                if let finishedGamesByYear = viewModel.dashboard?.finishedByYear {
                    let steps = finishedGamesByYear.map { finishedGame in
                        Text(String(finishedGame.year))
                    }

                    let indicationTypes = finishedGamesByYear.map { finishedGame in
                        StepperIndicationType.custom(
                            NumberedCircleView(text: finishedGame.total.toLeadingZerosString(decimalPlaces: 2), color: .main)
                            // TODO: Testar pra ver se eu consigo colocar um Text normal aqui, do SwiftUI mesmo
                        )
                    }
                    
                    ScrollView(.horizontal) {
                        StepperView()
                            .addSteps(steps)
                            .indicators(indicationTypes)
                            .stepIndicatorMode(StepperMode.horizontal)
                            .spacing(30)
                            .lineOptions(
                                StepperLineOptions.custom(1, Colors.black.rawValue)
                            )
                            .padding(.horizontal)
                            .padding(.top, 40)
                    }
                    .padding([.horizontal, .bottom])
                }
            }
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
                                SwiftUI.NavigationLink(value: boughtGame) {
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

// MARK: - DashboardView

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
                            SwiftUI.NavigationLink(value: GameplaySessionNavigation(key: key, value: gameplaySession)) {
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

extension DashboardView {
    var gameplaySessionsStepperView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.secondaryCardBackground)

            VStack(alignment: .center, spacing: 15) {
                VStack {
                    Text("Horas Jogadas por Ano")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                        .font(.cardTitle)
                }

                if let gameplaySessions = viewModel.gameplaySessions {
                    let steps = gameplaySessions.map {
                        Text(String($0.key))
                            .font(.dashboardGameTitle)
                    }

                    let indicationTypes = gameplaySessions.map { _ in
                        StepperIndicationType.custom(
                            NumberedCircleView(text: "999:99", width: 80).eraseToAnyView()
//                                Text("999:99")
//                                    .background(.red)
//                                    .frame(width: 80, height: 80)
                        )
                    }
                    
                    ScrollView(.horizontal) {
                        StepperView()
                            .addSteps(steps)
                            .indicators(indicationTypes)
                            .stepIndicatorMode(StepperMode.horizontal)
                            .spacing(30)
                            .lineOptions(
                                StepperLineOptions.custom(5, Colors.black.rawValue)
                            )
//                            .padding(.top, 40)
                    }
                    .frame(minHeight: 70)
                }
            }
            .padding()
        }
        .padding()
    }
}

// MARK: - Previews

#Preview("Dark Mode") {
    let _ = RepositoryContainer.dashboardRepository.register(factory: { MockDashboardRepository() })
    
    DashboardView(viewModel: DashboardViewModel()).preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    let _ = RepositoryContainer.dashboardRepository.register(factory: { MockDashboardRepository() })
    
    DashboardView(viewModel: DashboardViewModel()).preferredColorScheme(.light)
}
