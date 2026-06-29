//
//  GameDetailState.swift
//  GameNet
//
//  Created by Alliston Aleixo on 24/01/23.
//

import Foundation

struct GameDetailPreview: Hashable {
    let coverURL: String
    let name: String
    let platform: String
}

struct GameDetailRoute: Hashable {
    let id: String
    let preview: GameDetailPreview
}

extension GameDetailPreview {
    init(playingGame: PlayingGame) {
        coverURL = playingGame.coverURL
        name = playingGame.name
        platform = playingGame.platform
    }

    init(listItem: ListItem) {
        coverURL = listItem.cover ?? ""
        name = listItem.name ?? ""
        platform = listItem.platform ?? ""
    }

    init(game: Game) {
        coverURL = game.coverURL ?? ""
        name = game.name
        platform = game.platform ?? ""
    }

    init(gameplaySession: GameplaySession) {
        coverURL = gameplaySession.gameCover ?? ""
        name = gameplaySession.gameName ?? ""
        platform = ""
    }
}

struct GameFunRating: Equatable {
    let average: Decimal
    let isMock: Bool
}

enum GameDetailState: Equatable {
    case idle
    case loading
    case successGame(GameDetail)
    case successGameplays(GameplaySessions)
    case successSave(GameplaySession)
    case error(String)
}
