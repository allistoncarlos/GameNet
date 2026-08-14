//
//  ListCardModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 14/08/26.
//

import Foundation

struct ListCardModel: Identifiable, Equatable, Hashable {
    let list: GameNet.List
    var games: [ListItem]

    var id: String { list.id ?? list.name }
    var name: String { list.name }

    var previewGames: [ListItem] {
        Array(games.prefix(Self.previewLimit))
    }

    var overflowCount: Int? {
        guard games.count > Self.previewLimit else { return nil }
        return games.count - 2
    }

    private static let previewLimit = 3
}
