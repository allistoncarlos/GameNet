//
//  PlayingGamesLibraryCarousel.swift
//  GameNet
//
//  Vitrine dos jogos em andamento: pôsteres só com a frente da capa.
//

import SwiftUI

struct PlayingGamesLibraryCarousel: View {
    let games: [PlayingGame]
    var compact: Bool = true
    var onRefresh: () async -> Void = {}

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var selectedGameId: String?
    @State private var cardWidth = PlatformScreen.width

    private let cardInset: CGFloat = 16

    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }

    var body: some View {
        VStack(alignment: .leading, spacing: isLandscape ? 8 : 12) {
            Text("Jogando")
                .font(isLandscape ? .dashboardGameTitle : .cardTitle)
                .padding(.horizontal, cardInset)

            if games.isEmpty {
                Text("Nenhum jogo em andamento")
                    .font(.dashboardGameSubtitle)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .padding(.horizontal, cardInset)
            } else {
                vitrineCarousel
            }
        }
        .padding(.top, isLandscape ? 10 : 10)
        .padding(.bottom, isLandscape ? 10 : 12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.primaryCardBackground)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onWidthChange { cardWidth = $0 }
        .onAppear(perform: syncSelection)
        .onChangeCompat(of: games) { _ in
            syncSelection()
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("playing-library-vitrine")
    }

    private func itemId(for game: PlayingGame) -> String {
        game.id ?? game.name
    }

    private func syncSelection() {
        guard !games.isEmpty else {
            selectedGameId = nil
            return
        }

        if let selectedGameId, games.contains(where: { itemId(for: $0) == selectedGameId }) {
            return
        }

        selectedGameId = itemId(for: games[0])
    }

    private func sessionCaption(for game: PlayingGame, isStarted: Bool) -> String {
        if isStarted {
            return "Em sessão"
        }

        if let start = game.latestGameplaySession?.start {
            return start.toFormattedString()
        }

        return game.platform
    }

    private var focusesOneCover: Bool {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, *) {
            return true
        }

        return false
    }

    private func showsPlayButton(isFocused: Bool) -> Bool {
        !focusesOneCover || isFocused
    }
}

private extension PlayingGamesLibraryCarousel {
    var vitrineCoverSize: CGSize {
        PlatformMetrics.vitrineCoverSize(
            cardWidth: cardWidth,
            inset: cardInset,
            compact: compact,
            isLandscape: isLandscape,
            screenHeight: PlatformScreen.height
        )
    }

    var vitrineItemWidth: CGFloat {
        vitrineCoverSize.width
    }

    var vitrineHeight: CGFloat {
        vitrineCoverSize.height
    }

    var vitrineSideInset: CGFloat {
        max((cardWidth - vitrineItemWidth) / 2, cardInset)
    }

    var playButtonSize: CGFloat {
        isLandscape ? 32 : 40
    }

    var vitrineCarousel: some View {
        ScrollViewReader { proxy in
            libraryScroll {
                ForEach(games, id: \.id) { game in
                    let id = itemId(for: game)
                    let isFocused = id == selectedGameId

                    PlayingLibraryItem(playingGame: game, onRefresh: onRefresh) { viewModel, onRefresh in
                        vitrinePoster(
                            game: viewModel.playingGame,
                            viewModel: viewModel,
                            onRefresh: onRefresh,
                            isFocused: isFocused,
                            onSelect: {
                                selectGame(id, proxy: proxy)
                            }
                        )
                    }
                    .frame(width: vitrineItemWidth, height: vitrineHeight)
                    .libraryScrollIdentity(id)
                    .zIndex(isFocused ? 1 : 0)
                    .libraryCoverFlowTransition()
                }
            }
            .onChangeCompat(of: selectedGameId) { id in
                guard let id else { return }
                withAnimation(.gameNetSmooth) {
                    proxy.scrollTo(id, anchor: .center)
                }
            }
        }
        .frame(height: vitrineHeight)
    }

    func selectGame(_ id: String, proxy: ScrollViewProxy) {
        guard selectedGameId != id else { return }

        withAnimation(.gameNetSmooth) {
            selectedGameId = id
            proxy.scrollTo(id, anchor: .center)
        }
    }

    func vitrinePoster(
        game: PlayingGame,
        viewModel: GameCoverViewModel,
        onRefresh: @escaping () async -> Void,
        isFocused: Bool,
        onSelect: @escaping () -> Void
    ) -> some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if isFocused {
                    NavigationLink(value: game) {
                        vitrineArtwork(game: game, viewModel: viewModel, isFocused: true)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                    .contentShape(Rectangle())
                    .padding(.horizontal, -24)
                } else {
                    Button(action: onSelect) {
                        vitrineArtwork(game: game, viewModel: viewModel, isFocused: false)
                    }
                    .buttonStyle(.plain)
                }
            }

            if showsPlayButton(isFocused: isFocused) {
                PlayingGameSessionControls(
                    viewModel: viewModel,
                    onRefresh: onRefresh,
                    buttonSize: playButtonSize,
                    tint: .main
                )
                .padding(.trailing, isLandscape ? 8 : 10)
                .padding(.bottom, isLandscape ? 8 : 10)
            }
        }
    }

    func vitrineArtwork(
        game: PlayingGame,
        viewModel: GameCoverViewModel,
        isFocused: Bool
    ) -> some View {
        PlayingGameCoverArtwork(
            coverURL: game.coverURL,
            cornerRadius: 16,
            contentMode: .fill
        )
        .overlay {
            LinearGradient(
                colors: [.clear, .black.opacity(0.78)],
                startPoint: .center,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .allowsHitTesting(false)
        }
        .overlay(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: isLandscape ? 2 : 4) {
                Text(game.name)
                    .font(.dashboardGameTitle)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Text(sessionCaption(for: game, isStarted: viewModel.isStarted))
                    .font(.dashboardGameSubtitle)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)
            }
            .padding(.leading, isLandscape ? 10 : 12)
            .padding(.trailing, isLandscape ? 44 : 56)
            .padding(.bottom, isLandscape ? 10 : 14)
        }
        .shadow(
            color: .black.opacity(isFocused ? 0.28 : 0.1),
            radius: isFocused ? 12 : 4,
            y: isFocused ? 6 : 2
        )
    }

    @ViewBuilder
    func libraryScroll<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        let sideInset = vitrineSideInset

        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, *) {
            ScrollView(.horizontal) {
                HStack(spacing: -20) {
                    content()
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .scrollPosition(id: $selectedGameId, anchor: .center)
            .contentMargins(.horizontal, sideInset, for: .scrollContent)
            .scrollIndicators(.hidden)
        } else {
            ScrollView(.horizontal) {
                HStack(spacing: -20) {
                    Color.clear.frame(width: max(sideInset - 16, 0))
                    content()
                    Color.clear.frame(width: max(sideInset - 16, 0))
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

private extension View {
    @ViewBuilder
    func libraryScrollIdentity(_ id: String) -> some View {
        self.id(id).tag(id)
    }

    @ViewBuilder
    func libraryCoverFlowTransition() -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, *) {
            scrollTransition(.interactive, axis: .horizontal) { content, phase in
                content
                    .scaleEffect(phase.isIdentity ? 1 : 0.82, anchor: .center)
                    .opacity(phase.isIdentity ? 1 : 0.55)
            }
        } else {
            self
        }
    }
}
