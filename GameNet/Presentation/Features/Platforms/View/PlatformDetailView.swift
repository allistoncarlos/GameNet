//
//  PlatformDetailView.swift
//  GameNet
//

import CachedAsyncImage
import SwiftUI

struct PlatformDetailView: View {
    let platform: Platform

    @StateObject var viewModel: GamesViewModel
    @Binding var navigationPath: NavigationPath

    @State private var isLoading = true
    @State private var search = ""
    @State private var previewGames: [Game] = []
    @Namespace private var gameCoverTransitionNamespace

    var body: some View {
        GeometryReader { geometry in
            let columns = PlatformMetrics.gameGridColumns(for: geometry.size.width)

            ScrollView {
                VStack(spacing: 20) {
                    header

                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(displayedGames, id: \.id) { game in
                            if let gameId = game.id {
                                SwiftUI.NavigationLink(
                                    value: GameDetailRoute(
                                        id: gameId,
                                        preview: GameDetailPreview(game: game)
                                    )
                                ) {
                                    GameItemView(
                                        name: game.name,
                                        coverURL: game.coverURL ?? "",
                                        gameId: gameId
                                    )
                                }
                                .onAppear {
                                    Task {
                                        await viewModel.loadNextPage(currentGame: game)
                                    }
                                }
                            }
                        }
                    }

                    if !isLoading, displayedGames.isEmpty {
                        Text("Nenhum jogo nesta plataforma")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.top, 24)
                    }
                }
                .frame(maxWidth: PlatformMetrics.contentMaxWidth(for: geometry.size.width))
                .frame(maxWidth: .infinity)
                .padding(.horizontal, PlatformMetrics.horizontalPadding(for: geometry.size.width))
                .padding(.top, 8)
            }
        }
        .disabled(isLoading)
        .navigationView(title: "")
        .searchable(text: $search, prompt: Text("Buscar"))
        .onChange(of: search) { _, search in
            if search.isEmpty {
                Task { await viewModel.fetchData(clear: true) }
            }
        }
        .onSubmit(of: .search) {
            Task {
                await viewModel.fetchData(search: search, clear: true)
            }
        }
        .refreshable {
            Task {
                await viewModel.fetchData(clear: true)
            }
        }
        .navigationDestination(for: GameDetailRoute.self) { route in
            viewModel.showGameDetailView(
                navigationPath: $navigationPath,
                gameId: route.id,
                preview: route.preview
            )
            .gameDetailZoomTransition(gameId: route.id)
        }
        .gameCoverTransitionNamespace(gameCoverTransitionNamespace)
        .overlay(
            GameNetProgressHUD($isLoading, config: GameNetApp.hudConfig)
        )
        .onChange(of: viewModel.state) { _, state in
            isLoading = state == .loading
        }
        .onChange(of: viewModel.data) { _, games in
            CoverImageCache.prefetch(urls: games.compactMap(\.coverURL))
            refreshPreviewGames(from: games)
        }
        .task {
            await viewModel.fetchData()
        }
    }

    private var displayedGames: [Game] {
        search.isEmpty ? viewModel.data : viewModel.searchedGames
    }

    private func refreshPreviewGames(from games: [Game]) {
        guard !games.isEmpty else {
            previewGames = []
            return
        }

        guard previewGames.isEmpty else { return }
        previewGames = Array(games.shuffled().prefix(3))
    }

    private var gamesCountText: String {
        let count = viewModel.pagedList?.totalCount ?? viewModel.data.count
        return count == 1 ? "1 jogo" : "\(count) jogos"
    }

    private var header: some View {
        HStack(spacing: 0) {
            platformIllustration
                .frame(width: 118)
                .padding(.horizontal, 10)
                .padding(.vertical, 12)

            ZStack(alignment: .leading) {
                coverStrip
                titleFade

                GeometryReader { geometry in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(platform.name)
                            .font(.listCardTitle)
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .minimumScaleFactor(0.8)

                        Text(gamesCountText)
                            .font(.dashboardGameSubtitle)
                            .foregroundStyle(.white.opacity(0.86))
                    }
                    .shadow(color: .black.opacity(0.45), radius: 4, y: 1)
                    .padding(.leading, 14)
                    .padding(.trailing, 8)
                    .frame(width: geometry.size.width * 0.78, alignment: .leading)
                    .frame(maxHeight: .infinity, alignment: .center)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(Color.primaryCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.22), radius: 8, y: 3)
    }

    private var platformIllustration: some View {
        CachedAsyncImage(
            url: PlatformIllustration.url(for: platform.name),
            urlCache: CoverImageCache.urlCache
        ) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure:
                Image(systemName: "laptopcomputer")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            default:
                ProgressView()
            }
        }
    }

    @ViewBuilder
    private var coverStrip: some View {
        if previewGames.isEmpty {
            Color.primaryCardBackground
        } else {
            HStack(spacing: 0) {
                ForEach(Array(previewGames.enumerated()), id: \.offset) { _, game in
                    coverSlice(coverURL: game.coverURL)
                }
            }
        }
    }

    private var titleFade: some View {
        LinearGradient(
            stops: [
                .init(color: Color.primaryCardBackground, location: 0),
                .init(color: Color.primaryCardBackground.opacity(0.92), location: 0.22),
                .init(color: Color.primaryCardBackground.opacity(0.62), location: 0.46),
                .init(color: Color.primaryCardBackground.opacity(0.22), location: 0.7),
                .init(color: .clear, location: 1)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .allowsHitTesting(false)
    }

    private func coverSlice(coverURL: String?) -> some View {
        GeometryReader { geometry in
            CachedAsyncImage(
                url: URL(string: coverURL ?? ""),
                urlCache: CoverImageCache.urlCache
            ) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .scaleEffect(1.14)
                default:
                    Color.primaryCardBackground.opacity(0.65)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
        .frame(maxWidth: .infinity)
    }
}
