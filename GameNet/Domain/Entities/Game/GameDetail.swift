//
//  GameDetail.swift
//
//  Created by Alliston Aleixo on 20/05/22.
//

import Foundation

public struct GameDetail: Identifiable, Equatable, Hashable {

    // MARK: Lifecycle

    public init(
        id: String?,
        name: String,
        cover: String,
        platform: String,
        value: Decimal,
        boughtDate: Date?,
        gameplays: [Gameplay]?
    ) {
        self.id = id
        self.name = name
        self.cover = cover
        self.platform = platform
        self.value = value
        self.boughtDate = boughtDate
        self.gameplays = gameplays
    }

    // MARK: Public

    public var id: String?
    public var name: String
    public var cover: String
    public var platform: String
    public var value: Decimal
    public var boughtDate: Date?
    public var gameplays: [Gameplay]?

}
