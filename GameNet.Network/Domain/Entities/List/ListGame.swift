//
//  ListGame.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation
import SwiftData

@Model
public class ListGame: Identifiable, Equatable, Hashable {

    // MARK: Lifecycle

    public init(
        id: String?,
        name: String,
        games: [ListItem]?
    ) {
        self.id = id
        self.name = name
        self.games = games
    }

    // MARK: Public

    public var id: String?
    public var name: String
    public var games: [ListItem]?
    
    public func toRequest(userId: String?) -> ListGameRequest {
        let gamesRequest = games?.enumerated().map { (index, game) in
            return ListItemRequest(
                id: game.id,
                userId: userId ?? "",
                userGameId: game.userGameId ?? "",
                listId: self.id ?? "",
                gameName: game.name,
                platformName: game.platform ?? "",
                cover: game.cover ?? "",
                order: index,
                comment: game.comment ?? ""
            )
        } ?? []
        
        return ListGameRequest(id: id, name: name, games: gamesRequest)
    }

}
