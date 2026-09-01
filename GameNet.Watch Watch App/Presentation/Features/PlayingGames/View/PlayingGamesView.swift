//
//  PlayingGamesView.swift
//  GameNet.Watch Watch App
//
//  Created by Alliston Aleixo on 06/01/23.
//

import SwiftUI
import WatchKit
#if canImport(UIKit)
import UIKit
#endif

struct PlayingGamesView: View {
    @ObservedObject var viewModel: PlayingGamesViewModel
    @State private var covers: [String: UIImage] = [:]
    @State private var selectedIndex = 0
    @State private var crownValue = 0.0
    @FocusState private var isCrownFocused: Bool

    private var artworkSize: CGSize {
        let bounds = WKInterfaceDevice.current().screenBounds
        let width = min(bounds.width * 0.72, bounds.height * 0.62)
        return CGSize(width: width, height: width * 1.5)
    }

    var body: some View {
        Group {
            switch viewModel.uiState {
            case .loading:
                ProgressView()
            case .notLogged:
                statusView(
                    title: "Login necessário",
                    subtitle: "Abra o GameNet no iPhone e faça login."
                )
            case .empty:
                statusView(
                    title: "Nenhum jogo em andamento",
                    subtitle: "Adicione jogos na seção Jogando do iPhone."
                )
            case .error(let message):
                statusView(
                    title: "Não foi possível carregar",
                    subtitle: message
                )
            case .content:
                carouselContent
            }
        }
        .task {
            await viewModel.load()
            syncSelection()
            reloadCovers()
        }
        .onChange(of: viewModel.games) { _, _ in
            syncSelection()
            reloadCovers()
        }
        .onChange(of: selectedIndex) { _, _ in
            applyVisibleCovers()
        }
        .onReceive(WatchConnectivityManager.shared.$coverRevision) { _ in
            reloadCovers()
        }
    }

    private var carouselContent: some View {
        let games = viewModel.games
        let size = artworkSize
        let selectedId = games.indices.contains(selectedIndex) ? games[selectedIndex].id : nil

        return ZStack {
            HStack(spacing: -size.width * 0.42) {
                if selectedIndex == 0 {
                    Color.clear
                        .frame(width: size.width * 0.82, height: size.height * 0.82)
                }

                ForEach(visibleGames(from: games)) { game in
                    WatchVitrinePage(
                        game: game,
                        cover: covers[game.id],
                        size: size,
                        isFocused: game.id == selectedId,
                        isSaving: viewModel.isSaving && game.id == selectedId,
                        onToggle: {
                            Task { await viewModel.toggleGameplay(gameId: game.id) }
                        },
                        onSelect: {
                            if let index = games.firstIndex(where: { $0.id == game.id }) {
                                select(index, games: games)
                            }
                        }
                    )
                    .equatable()
                    .zIndex(game.id == selectedId ? 1 : 0)
                }

                if selectedIndex == games.count - 1 {
                    Color.clear
                        .frame(width: size.width * 0.82, height: size.height * 0.82)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .focusable()
        .focused($isCrownFocused)
        .digitalCrownRotation(
            $crownValue,
            from: 0,
            through: Double(max(games.count - 1, 0)),
            by: 1,
            sensitivity: .low,
            isContinuous: false,
            isHapticFeedbackEnabled: true
        )
        .onAppear {
            isCrownFocused = true
        }
        .onChange(of: crownValue) { _, newValue in
            select(Int(newValue.rounded()), games: games)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 16)
                .onEnded { value in
                    if value.translation.width < -20 {
                        select(selectedIndex + 1, games: games)
                    } else if value.translation.width > 20 {
                        select(selectedIndex - 1, games: games)
                    }
                }
        )
        .animation(.easeOut(duration: 0.18), value: selectedIndex)
    }

    private func visibleGames(from games: [WatchPlayingGame]) -> [WatchPlayingGame] {
        guard games.indices.contains(selectedIndex) else { return [] }

        var items: [WatchPlayingGame] = []
        if selectedIndex > 0 {
            items.append(games[selectedIndex - 1])
        }
        items.append(games[selectedIndex])
        if selectedIndex + 1 < games.count {
            items.append(games[selectedIndex + 1])
        }
        return items
    }

    private func select(_ index: Int, games: [WatchPlayingGame]) {
        guard games.indices.contains(index), index != selectedIndex else { return }
        selectedIndex = index
        crownValue = Double(index)
    }

    private func syncSelection() {
        let games = viewModel.games
        guard !games.isEmpty else {
            selectedIndex = 0
            crownValue = 0
            return
        }

        if !games.indices.contains(selectedIndex) {
            selectedIndex = 0
            crownValue = 0
        }
    }

    private func reloadCovers() {
        applyVisibleCovers()

        let allIds = viewModel.games.map(\.id)
        let visibleIds = Set(visibleGames(from: viewModel.games).map(\.id))
        let remaining = allIds.filter { !visibleIds.contains($0) }
        guard !remaining.isEmpty else { return }

        Task { @MainActor in
            let size = artworkSize
            let scale = WKInterfaceDevice.current().screenScale
            WatchConnectivityManager.shared.preloadDisplayCovers(
                for: remaining,
                size: size,
                scale: scale
            )
            mergeCovers(ids: allIds, size: size, scale: scale)
        }
    }

    private func applyVisibleCovers() {
        let size = artworkSize
        let scale = WKInterfaceDevice.current().screenScale
        mergeCovers(
            ids: visibleGames(from: viewModel.games).map(\.id),
            size: size,
            scale: scale
        )
    }

    private func mergeCovers(ids: [String], size: CGSize, scale: CGFloat) {
        var next = covers
        var changed = false
        let validIds = Set(viewModel.games.map(\.id))

        for key in next.keys where !validIds.contains(key) {
            next.removeValue(forKey: key)
            changed = true
        }

        for id in ids {
            let image = WatchConnectivityManager.shared.displayCover(
                for: id,
                size: size,
                scale: scale
            )
            if !isSameImage(next[id], image) {
                next[id] = image
                changed = true
            }
        }

        if changed {
            covers = next
        }
    }

    private func isSameImage(_ lhs: UIImage?, _ rhs: UIImage?) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil):
            return true
        case let (left?, right?):
            return left === right
        default:
            return false
        }
    }

    private func statusView(title: String, subtitle: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
    }
}

private struct WatchVitrinePage: View, Equatable {
    let game: WatchPlayingGame
    let cover: UIImage?
    let size: CGSize
    let isFocused: Bool
    let isSaving: Bool
    let onToggle: () -> Void
    let onSelect: () -> Void

    static func == (lhs: WatchVitrinePage, rhs: WatchVitrinePage) -> Bool {
        lhs.game == rhs.game
            && lhs.cover === rhs.cover
            && lhs.size == rhs.size
            && lhs.isFocused == rhs.isFocused
            && lhs.isSaving == rhs.isSaving
    }

    var body: some View {
        let scale: CGFloat = isFocused ? 1 : 0.82

        ZStack(alignment: .bottomTrailing) {
            coverView

            if isFocused {
                VStack(alignment: .leading, spacing: 1) {
                    Text(game.name)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    if let caption = sessionCaption {
                        Text(caption)
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.85))
                            .lineLimit(1)
                    }
                }
                .padding(.leading, 8)
                .padding(.trailing, 36)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .allowsHitTesting(false)

                Button(action: onToggle) {
                    Image(systemName: game.isStarted ? "stop.fill" : "play.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.gameNetMain, in: Circle())
                }
                .buttonStyle(.plain)
                .disabled(isSaving)
                .padding(.trailing, 6)
                .padding(.bottom, 6)
            }
        }
        .frame(width: size.width, height: size.height)
        .scaleEffect(scale)
        .opacity(isFocused ? 1 : 0.45)
        .onTapGesture(perform: onSelect)
        .allowsHitTesting(true)
    }

    @ViewBuilder
    private var coverView: some View {
        if let cover {
            Image(uiImage: cover)
                .interpolation(.none)
        } else {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.gray.opacity(0.22))
                .overlay {
                    Image(systemName: "gamecontroller.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
        }
    }

    private var sessionCaption: String? {
        if game.isStarted {
            return "Em sessão"
        }

        if let iso = game.latestSessionStartISO {
            return WatchConnectivityDateCodec.displayString(fromISO: iso)
        }

        return nil
    }
}
