//
//  PlayingGame.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation
import SwiftData

@Model
public class PlayingGame: Identifiable, Equatable, Hashable {
    public var id: String?
    public var name: String
    public var platform: String
    public var coverURL: String
    public var latestGameplaySession: LatestGameplaySession?

    public init(id: String?,
                name: String,
                platform: String,
                coverURL: String,
                latestGameplaySession: LatestGameplaySession?
    ) {
        self.id = id
        self.name = name
        self.platform = platform
        self.coverURL = coverURL
        self.latestGameplaySession = latestGameplaySession
    }
}
