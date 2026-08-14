//
//  TheGamesDBGame.swift
//  GameNet
//

import Foundation

struct TheGamesDBGame: Identifiable, Hashable {
    let id: Int
    let name: String
    let platformId: Int?
    var platformName: String?
    let released: String?
    var boxartURL: URL?

    init(
        id: Int,
        name: String,
        platformId: Int?,
        platformName: String? = nil,
        released: String?,
        boxartURL: URL? = nil
    ) {
        self.id = id
        self.name = name
        self.platformId = platformId
        self.platformName = platformName
        self.released = released
        self.boxartURL = boxartURL
    }
}
