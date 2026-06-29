//
//  LatestGameplaySession.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation
import SwiftData

@Model
public class LatestGameplaySession: Identifiable, Equatable, Hashable {

    // MARK: Lifecycle

    public init(
        id: String?,
        userGameId: String,
        start: Date,
        finish: Date?
    ) {
        self.id = id
        self.userGameId = userGameId
        self.start = start
        self.finish = finish
    }

    // MARK: Public

    public var id: String?
    public var userGameId: String
    public var start: Date
    public var finish: Date?
}
