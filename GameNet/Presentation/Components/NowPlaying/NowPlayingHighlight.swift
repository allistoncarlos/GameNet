//
//  NowPlayingHighlight.swift
//  GameNet
//
//  Destaque do jogo com sessão de gameplay em andamento.
//

import Foundation

/// Jogo que está sendo jogado agora, derivado de uma `GameplaySession` sem `finish`.
///
/// A sessão aberta é a fonte de verdade: ela pode existir para um jogo que não
/// aparece em `Dashboard.playingGames` (jogo sem Gameplay em andamento).
/// Quando o jogo também está na lista do dashboard, reaproveitamos aquele
/// `PlayingGame` (capa/plataforma já resolvidas) trocando apenas a última sessão.
struct NowPlayingHighlight: Equatable, Hashable, Identifiable {

    // MARK: Lifecycle

    init(session: GameplaySession, playingGame: PlayingGame) {
        self.session = session
        self.playingGame = playingGame
    }

    // MARK: Internal

    let session: GameplaySession
    let playingGame: PlayingGame

    var id: String { session.id ?? session.userGameId }
    var name: String { playingGame.name }
    var platform: String { playingGame.platform }
    var coverURL: String { playingGame.coverURL }
    var userGameId: String { session.userGameId }

    /// Instante absoluto do início da sessão.
    ///
    /// `start` vem da API já deslocado pelo fuso (horário local tratado como UTC),
    /// então o timer precisa desfazer esse deslocamento — igual à Live Activity.
    var absoluteStart: Date {
        session.start.undoingTimeZoneDateShift()
    }

    /// Hora de início em horário local ("HH:mm").
    var startTimeLabel: String {
        session.start.toFormattedString(dateFormat: "HH:mm")
    }
}

extension NowPlayingHighlight {
    /// Monta o destaque a partir das sessões já carregadas por ano.
    ///
    /// Escolhe a sessão aberta (`finish == nil`) de início mais recente.
    static func make(
        gameplaySessionsByYear: [Int: GameplaySessions],
        playingGames: [PlayingGame]?
    ) -> NowPlayingHighlight? {
        let openSessions = gameplaySessionsByYear
            .values
            .flatMap { $0.sessions.compactMap { $0 } }
            .filter { $0.finish == nil }

        guard let session = openSessions.max(by: { $0.start < $1.start }) else {
            return nil
        }

        let latestGameplaySession = LatestGameplaySession(
            id: session.id,
            userGameId: session.userGameId,
            start: session.start,
            finish: session.finish
        )

        if var playingGame = playingGames?.first(where: { $0.id == session.userGameId }) {
            playingGame.latestGameplaySession = latestGameplaySession

            return NowPlayingHighlight(session: session, playingGame: playingGame)
        }

        return NowPlayingHighlight(
            session: session,
            playingGame: PlayingGame(
                id: session.userGameId,
                name: session.gameName,
                platform: session.platformName,
                coverURL: session.gameCover,
                latestGameplaySession: latestGameplaySession
            )
        )
    }
}
