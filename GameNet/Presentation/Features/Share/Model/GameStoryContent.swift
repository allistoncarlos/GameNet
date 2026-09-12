//
//  GameStoryContent.swift
//  GameNet
//
//  Dados exibidos no story "estou jogando" do Instagram.
//

import Foundation

/// Conteúdo renderizado no story: capa, jogo, plataforma e tempo de jogo.
///
/// Quando existe sessão aberta, `sessionStart` guarda o instante absoluto
/// (já com `undoingTimeZoneDateShift()` aplicado) para o cronômetro.
struct GameStoryContent: Equatable, Identifiable {

    // MARK: Lifecycle

    init(
        gameName: String,
        platform: String,
        coverURL: String,
        sessionStart: Date? = nil,
        totalGameplayTime: String? = nil
    ) {
        self.gameName = gameName
        self.platform = platform
        self.coverURL = coverURL
        self.sessionStart = sessionStart
        self.totalGameplayTime = totalGameplayTime
    }

    /// Destaque "Jogando agora" — sempre traz sessão aberta.
    init(highlight: NowPlayingHighlight) {
        self.init(
            gameName: highlight.name,
            platform: highlight.platform,
            coverURL: highlight.coverURL,
            sessionStart: highlight.absoluteStart,
            totalGameplayTime: highlight.session.totalGameplayTime
        )
    }

    /// Jogo do carrossel: só vira "jogando agora" se a última sessão estiver aberta.
    init(playingGame: PlayingGame) {
        var sessionStart: Date?

        if let session = playingGame.latestGameplaySession, session.finish == nil {
            sessionStart = session.start.undoingTimeZoneDateShift()
        }

        self.init(
            gameName: playingGame.name,
            platform: playingGame.platform,
            coverURL: playingGame.coverURL,
            sessionStart: sessionStart
        )
    }

    // MARK: Internal

    let gameName: String
    let platform: String
    let coverURL: String
    let sessionStart: Date?
    let totalGameplayTime: String?

    var id: String { "\(gameName)-\(coverURL)" }

    var isPlayingNow: Bool { sessionStart != nil }

    /// Tempo decorrido da sessão aberta, congelado no instante informado.
    func elapsedText(at date: Date = Date()) -> String? {
        guard let sessionStart else { return nil }

        return NowPlayingSessionTimer.elapsedText(from: sessionStart, to: date)
    }
}
