//
//  NowPlayingCenter.swift
//  GameNet
//
//  Estado compartilhado da sessão de gameplay em andamento.
//

import Combine
import Factory
import Foundation

/// Fonte única do destaque "Jogando agora" fora do Dashboard.
///
/// O Dashboard carrega as sessões de todos os anos e empurra o resultado com
/// `update(_:)`; as demais abas consultam o ano corrente sob demanda.
@MainActor
final class NowPlayingCenter: ObservableObject {

    // MARK: Lifecycle

    private init() {}

    // MARK: Internal

    static let shared = NowPlayingCenter()

    @Published private(set) var highlight: NowPlayingHighlight?

    /// Recebe o destaque já calculado pelo Dashboard (cobre sessões de anos anteriores).
    func update(_ highlight: NowPlayingHighlight?) {
        self.highlight = highlight
    }

    /// Consulta as sessões do ano corrente e atualiza o destaque.
    func refresh() async {
        guard !isRefreshing else { return }

        isRefreshing = true
        defer { isRefreshing = false }

        let year = Calendar.current.component(.year, from: Date.timeZoneDate())

        guard let gameplaySessions = await repository.fetchGameplaySessionsByYear(year: year, month: nil) else {
            return
        }

        highlight = NowPlayingHighlight.make(
            gameplaySessionsByYear: [year: gameplaySessions],
            playingGames: nil
        )
    }

    // MARK: Private

    @Injected(\.gameplaySessionRepository) private var repository
    private var isRefreshing = false
}
