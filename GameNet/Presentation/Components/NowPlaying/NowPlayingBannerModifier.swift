//
//  NowPlayingBannerModifier.swift
//  GameNet
//
//  Faixa "Jogando agora" fixa acima da tab bar nas demais abas.
//

import SwiftUI

extension View {
    /// Exibe a faixa da sessão em andamento ancorada na base da tela.
    func nowPlayingBanner() -> some View {
        modifier(NowPlayingBannerModifier())
    }
}

// MARK: - NowPlayingBannerModifier

private struct NowPlayingBannerModifier: ViewModifier {

    // MARK: Internal

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom, spacing: 0) {
                banner
            }
            .task {
                await center.refresh()
            }
            .onChangeCompat(of: scenePhase) { phase in
                guard phase == .active else { return }

                Task { await center.refresh() }
            }
            .onReceive(NotificationCenter.default.publisher(for: .gameplaySessionDidChangeFromWidget)) { _ in
                Task { await center.refresh() }
            }
    }

    // MARK: Private

    @ObservedObject private var center = NowPlayingCenter.shared
    @Environment(\.scenePhase) private var scenePhase

    @ViewBuilder
    private var banner: some View {
        if let highlight = center.highlight {
            NowPlayingBanner(
                highlight: highlight,
                onRefresh: {
                    await center.refresh()
                }
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }
}
