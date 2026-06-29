//
//  GameplaySessions.swift
//
//  Created by Alliston Aleixo on 20/05/22.
//

import Foundation
import SwiftData

@Model
public class GameplaySessions: Identifiable, Equatable, Hashable {

    // MARK: Lifecycle

    public init(
        id: String?,
        sessions: [GameplaySession?],
        totalGameplayTime: String,
        averageGameplayTime: String
    ) {
        self.id = id
        self.sessions = sessions
        self.totalGameplayTime = totalGameplayTime
        self.averageGameplayTime = averageGameplayTime
    }

    // MARK: Public

    public var id: String?
    public var sessions: [GameplaySession?]
    public var totalGameplayTime: String
    public var averageGameplayTime: String
}
