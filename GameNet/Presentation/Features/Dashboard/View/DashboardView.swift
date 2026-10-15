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

    // MARK: Internal

    @ObservedObject var viewModel: DashboardViewModel
    @State var isLoading = false
    @State private var availableWidth = PlatformScreen.width
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        NavigationStack(path: $presentedViews) {
            ScrollView {
                dashboardContent
            }
            .dashboardScrollTopInset()
            .onWidthChange { newWidth in
                availableWidth = newWidth
            }
            .refreshable {
                // Roda em um Task desacoplado do ciclo de vida do `.refreshable`
                // para que desabilitar o ScrollView (isLoading) não cancele a
                // requisição (explicitlyCancelled). O `await .value` mantém o
                // indicador nativo visível até o carregamento terminar.
                await Task { await viewModel.fetchData() }.value
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
        }
        .gameCoverTransitionNamespace(gameCoverTransitionNamespace)
        .overlay(
            GameNetProgressHUD($isLoading, config: GameNetApp.hudConfig)
        )
        .onChangeCompat(of: viewModel.state) { state in
            isLoading = state == .loading
        }
        .onReceive(NotificationCenter.default.publisher(for: .gameplaySessionDidChangeFromWidget)) { _ in
            Task {
                #if os(iOS)
                await GameplayLiveActivityManager.syncFromStore()
                #endif
                await viewModel.fetchData()
            }
        }
        .onChangeCompat(of: scenePhase) { phase in
            guard phase == .active else { return }
            Task {
                #if os(iOS)
                await GameplayLiveActivityManager.syncFromStore()
                #endif
                await viewModel.fetchData()
            }
        }
        .task {
            await viewModel.fetchData()
        }
    }

    // MARK: Private

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dashboardCardFillsHeight) private var fillsRowHeight
    @State private var presentedViews = NavigationPath()
    @Namespace private var gameCoverTransitionNamespace

    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }

    private var usesCompactLayout: Bool {
        PlatformMetrics.dashboardUsesCompactLayout(
            width: availableWidth,
            isLandscape: isLandscape
        )
    }

    private var usesPairedCards: Bool {
        PlatformMetrics.dashboardUsesPairedCards(width: availableWidth)
    }

    @ViewBuilder
    private var dashboardContent: some View {
        if usesCompactLayout {
            compactDashboardContent
                .environment(\.dashboardUsesOuterPadding, true)
        } else {
            regularDashboardContent
                .environment(\.dashboardUsesOuterPadding, false)
                .gameNetDashboardWidth(for: availableWidth)
                .padding(.horizontal, PlatformMetrics.horizontalPadding(for: availableWidth))
        }
    }

    @ViewBuilder
    private var compactDashboardContent: some View {
        VStack(spacing: -20) {
            playingLibraryCards

            if viewModel.gameplaySessions != nil {
                gameplaySessions
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

            appVersionFooter
        }
    }

    @ViewBuilder
    private var regularDashboardContent: some View {
        if usesPairedCards {
            pairedDashboardContent
        } else {
            stackedDashboardContent
        }
    }

    @ViewBuilder
    private var stackedDashboardContent: some View {
        VStack(spacing: 16) {
            playingLibraryCards

            if viewModel.gameplaySessions != nil {
                gameplaySessions
            }

            if viewModel.dashboard?.totalGames != nil {
                physicalDigitalCard
            }

            annualGameplayProgressCard

            if viewModel.dashboard?.finishedByYear != nil {
                finishedByYearTimelineCard
            }

            if viewModel.dashboard?.boughtByYear != nil {
                boughtByYearCard
            }

            if viewModel.dashboard?.gamesByPlatform != nil {
                gamesByPlatformCard
            }

            appVersionFooter
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var pairedDashboardContent: some View {
        let hasHours = viewModel.gameplaySessions != nil
        let hasLibrary = viewModel.dashboard?.totalGames != nil
        let hasFinished = viewModel.dashboard?.finishedByYear != nil
        let hasBought = viewModel.dashboard?.boughtByYear != nil

        Grid(alignment: .topLeading, horizontalSpacing: 16, verticalSpacing: 16) {
            GridRow {
                playingLibraryCards
                    .gridCellColumns(2)
            }

            GridRow {
                if hasHours {
                    gameplaySessions
                        .dashboardFillRowHeight()
                        .gridCellColumns(hasLibrary ? 1 : 2)
                }

                if hasLibrary {
                    physicalDigitalCard
                        .dashboardFillRowHeight()
                        .gridCellColumns(hasHours ? 1 : 2)
                }
            }

            GridRow {
                annualGameplayProgressCard
                    .gridCellColumns(2)
            }

            GridRow {
                if hasFinished {
                    finishedByYearTimelineCard
                        .dashboardFillRowHeight()
                        .gridCellColumns(hasBought ? 1 : 2)
                }

                if hasBought {
                    boughtByYearCard
                        .dashboardFillRowHeight()
                        .gridCellColumns(hasFinished ? 1 : 2)
                }
            }

            GridRow {
                if viewModel.dashboard?.gamesByPlatform != nil {
                    gamesByPlatformCard
                        .gridCellColumns(2)
                }
            }

            GridRow {
                appVersionFooter
                    .gridCellColumns(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(.vertical, 8)
    }

    private var annualChartHeight: CGFloat {
        PlatformMetrics.annualChartHeight(compact: usesCompactLayout, isLandscape: isLandscape)
    }

    /// Jogos do carrossel: o jogo em sessão entra na frente mesmo quando não
    /// está em `playingGames` (sessão aberta sem Gameplay).
    private var carouselGames: [PlayingGame] {
        var games = orderedPlayingGames

        guard let highlightedGame = viewModel.nowPlayingHighlight?.playingGame else {
            return games
        }

        games.removeAll { $0.id == highlightedGame.id }
        games.insert(highlightedGame, at: 0)

        return games
    }

    private var carouselHighlightedGameId: String? {
        guard let highlightedGame = viewModel.nowPlayingHighlight?.playingGame else {
            return nil
        }

        return highlightedGame.id ?? highlightedGame.name
    }

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
}

extension DashboardView {
    var appVersionFooter: some View {
        Text("Versão \(viewModel.appVersion)")
            .font(.dashboardGameSubtitle)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.top, 30)
            .padding(.bottom)
    }
}

extension DashboardView {
    @ViewBuilder
    var playingLibraryCards: some View {
        if viewModel.dashboard?.playingGames != nil || carouselHighlightedGameId != nil {
            PlayingGamesLibraryCarousel(
                games: carouselGames,
                compact: usesCompactLayout,
                highlightedGameId: carouselHighlightedGameId,
                onRefresh: {
                    await viewModel.fetchData()
                }
            )
            .padding(.horizontal, usesCompactLayout ? 16 : 0)
            .padding(.bottom, usesCompactLayout ? 8 : 0)
            .padding(.top, 0)
        }
    }
}

extension DashboardView {
    var annualGameplayProgressCard: some View {
        AnnualGameplayProgressChartView(
            series: viewModel.annualGameplayProgress,
            chartHeight: annualChartHeight,
            defaultVisibleDomainLength: PlatformMetrics.annualChartVisibleDays(for: availableWidth)
        )
    }
}

extension DashboardView {
    var physicalDigitalCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            physicalDigitalHeader

            if let physicalDigital = viewModel.dashboard?.physicalDigital {
                physicalDigitalProportionBar(
                    digital: physicalDigital.digital,
                    physical: physicalDigital.physical
                )

                HStack(spacing: 12) {
                    physicalDigitalTile(
                        icon: "arrow.down.circle.fill",
                        title: "Digitais",
                        value: physicalDigital.digital,
                        total: physicalDigital.digital + physicalDigital.physical
                    )

                    physicalDigitalTile(
                        icon: "opticaldisc.fill",
                        title: "Físicos",
                        value: physicalDigital.physical,
                        total: physicalDigital.digital + physicalDigital.physical
                    )
                }
            }

            if fillsRowHeight {
                Spacer(minLength: 0)
            }
        }
        .foregroundStyle(.white)
        .padding(20)
        .dashboardCardHeight()
        .gameNetGlassEffect(
            .tinted(Color.secondaryCardBackground),
            in: .rect(cornerRadius: 20)
        )
        .dashboardOuterPadding()
    }

    private var physicalDigitalHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 0) {
                if let totalGames = viewModel.dashboard?.totalGames {
                    Text("\(totalGames)")
                        .font(.cardTitle)
                    Text("Jogos na biblioteca")
                        .font(.dashboardGameSubtitle)
                        .opacity(0.85)
                }
            }

            Spacer()

            if let formattedTotalPrice = viewModel.dashboard?.totalPrice?.toCurrencyString() {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Investido")
                        .font(.dashboardGameSubtitle)
                        .opacity(0.85)
                    Text(formattedTotalPrice)
                        .font(.dashboardGameTitle)
                }
            }
        }
    }

    private func physicalDigitalProportionBar(digital: Int, physical: Int) -> some View {
        let total = max(digital + physical, 1)
        let digitalFraction = CGFloat(digital) / CGFloat(total)

        return GeometryReader { geometry in
            let digitalWidth = geometry.size.width * digitalFraction

            HStack(spacing: 0) {
                Rectangle()
                    .fill(.white)
                    .frame(width: digitalWidth)
                Rectangle()
                    .fill(.white.opacity(0.35))
            }
            .clipShape(Capsule())
        }
        .frame(height: 8)
    }

    private func physicalDigitalTile(icon: String, title: String, value: Int, total: Int) -> some View {
        let percentage = total > 0 ? Int((Double(value) / Double(total) * 100).rounded()) : 0

        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.dashboardGameSubtitle)
                Text(title)
                    .font(.dashboardGameSubtitle)
                Spacer()
                Text("\(percentage)%")
                    .font(.dashboardGameSubtitle)
                    .opacity(0.85)
            }

            Text("\(value)")
                .font(.dashboardGameTitle)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.15))
        )
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
    var boughtByYearCard: some View {
        BoughtByYearView(
            boughtByYear: viewModel.dashboard?.boughtByYear ?? [],
            onYearTapped: { boughtGame in
                presentedViews.append(boughtGame)
            }
        )
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

                if let gamesByPlatform = viewModel.dashboard?.gamesByPlatform?.platforms {
                    if usesCompactLayout {
                        compactGamesByPlatformList(gamesByPlatform)
                    } else {
                        regularGamesByPlatformGrid(gamesByPlatform)
                    }
                }

                if fillsRowHeight {
                    Spacer(minLength: 0)
                }
            }
            .padding()
        }
        .dashboardCardHeight()
        .dashboardOuterPadding()
    }

    private func compactGamesByPlatformList(_ platforms: [PlatformGame]) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(platforms, id: \.id) { gameByPlatform in
                gamesByPlatformRow(gameByPlatform)
            }
        }
    }

    private func regularGamesByPlatformGrid(_ platforms: [PlatformGame]) -> some View {
        LazyVGrid(
            columns: PlatformMetrics.gamesByPlatformColumns(for: availableWidth),
            alignment: .leading,
            spacing: 10
        ) {
            ForEach(platforms, id: \.id) { gameByPlatform in
                gamesByPlatformRow(gameByPlatform)
                    .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white.opacity(0.08))
                    )
            }
        }
    }

    private func gamesByPlatformRow(_ gameByPlatform: PlatformGame) -> some View {
        HStack(spacing: 20) {
            Text(gameByPlatform.platformGamesTotal.toLeadingZerosString(decimalPlaces: 3))
                .font(.dashboardGameTitle)
            Text(gameByPlatform.name)
                .font(.dashboardGameTitle)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
        }
    }
}

// MARK: - DashboardView

extension DashboardView {
    var gameplaySessions: some View {
        PlayedHoursByYearView(
            gameplaySessions: viewModel.gameplaySessions ?? [:],
            onYearTapped: { navigation in
                presentedViews.append(navigation)
            }
        )
    }
}

