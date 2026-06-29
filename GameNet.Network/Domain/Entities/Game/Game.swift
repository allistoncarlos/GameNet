//
//  Game.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation
import SwiftData

@Model
public class Game: Identifiable, Equatable, Hashable {

    // MARK: Lifecycle

    public init(
        id: String?,
        name: String,
        cover: Data?,
        coverURL: String?,
        platformId: String,
        platform: String
    ) {
        self.id = id
        self.name = name
        self.cover = cover
        self.coverURL = coverURL
        self.platformId = platformId
        self.platform = platform
    }

    // MARK: Public

    public var id: String?
    public var name: String
    public var cover: Data?
    public var coverURL: String?
    public var platformId: String
    public var platform: String?

    public func toRequest() -> GameEditRequest {
        return GameEditRequest(
            id: id,
            name: name,
            cover: cover ?? Data(),
            platformId: platformId
        )
    }
}
