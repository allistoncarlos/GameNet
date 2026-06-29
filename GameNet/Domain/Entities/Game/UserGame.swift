//
//  UserGame.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation

public struct UserGame: Identifiable, Equatable, Hashable {

    // MARK: Lifecycle

    public init(
        id: String?,
        gameId: String,
        userId: String,
        price: Double,
        boughtDate: Date?,
        have: Bool,
        want: Bool,
        digital: Bool,
        original: Bool
    ) {
        self.id = id
        self.gameId = gameId
        self.userId = userId
        self.price = price
        self.boughtDate = boughtDate
        self.have = have
        self.want = want
        self.digital = digital
        self.original = original
    }

    // MARK: Public

    public var id: String?
    public var gameId: String
    public var userId: String
    public var price: Double
    public var boughtDate: Date?
    public var have: Bool
    public var want: Bool
    public var digital: Bool
    public var original: Bool

    public func toRequest() -> UserGameEditRequest {
        return UserGameEditRequest(
            id: nil,
            gameId: gameId,
            userId: userId,
            price: price,
            boughtDate: boughtDate,
            have: have,
            want: want,
            digital: digital,
            original: original
        )
    }
}
