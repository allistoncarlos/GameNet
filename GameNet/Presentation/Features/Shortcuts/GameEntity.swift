//
//  GameEntity.swift
//  GameNet
//

#if os(iOS)
import AppIntents
import Foundation

struct GameEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Game")
    static var defaultQuery = GameEntityQuery()

    var id: String
    var name: String
    var platform: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(name)",
            subtitle: "\(platform)"
        )
    }
}

struct GameEntityQuery: EntityStringQuery {
    func entities(for identifiers: [GameEntity.ID]) async throws -> [GameEntity] {
        let service = AddGameToListService.make()
        var result: [GameEntity] = []

        for id in identifiers {
            if let game = await service.game(id: id), let gameId = game.id {
                result.append(GameEntity(id: gameId, name: game.name, platform: game.platform))
            }
        }

        if result.count == identifiers.count {
            return result
        }

        let extras = await service.suggestedGames().compactMap { game -> GameEntity? in
            guard let id = game.id, identifiers.contains(id) else { return nil }
            return GameEntity(id: id, name: game.name, platform: game.platform ?? "")
        }

        let existingIds = Set(result.map(\.id))
        return result + extras.filter { !existingIds.contains($0.id) }
    }

    func suggestedEntities() async throws -> [GameEntity] {
        await AddGameToListService.make().suggestedGames().compactMap { game in
            guard let id = game.id else { return nil }
            return GameEntity(id: id, name: game.name, platform: game.platform ?? "")
        }
    }

    func entities(matching string: String) async throws -> [GameEntity] {
        await AddGameToListService.make().searchGames(matching: string).compactMap { game in
            guard let id = game.id else { return nil }
            return GameEntity(id: id, name: game.name, platform: game.platform ?? "")
        }
    }
}
#endif
