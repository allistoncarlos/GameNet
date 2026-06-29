//
//  PlatformGames.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation
import SwiftData

// MARK: - PlatformGame

@Model
public class PlatformGame: Identifiable, Equatable, Hashable {

    // MARK: Lifecycle

    public init(
        id: String?,
        name: String,
        platformGamesTotal: Int
    ) {
        self.id = id
        self.name = name
        self.platformGamesTotal = platformGamesTotal
    }

    // MARK: Public

    public var id: String?
    public var name: String
    public var platformGamesTotal: Int

}

// MARK: - PlatformGames

@Model
public class PlatformGames: Identifiable, Equatable, Hashable {

    // MARK: Lifecycle

    public init(total: Int, platforms: [PlatformGame]) {
        self.id = UUID().uuidString
        self.total = total
        self.platforms = platforms
    }

    // MARK: Public

    public var id: String?
    public var total: Int
    public var platforms: [PlatformGame]
}
