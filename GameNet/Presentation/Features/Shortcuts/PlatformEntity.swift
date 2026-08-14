//
//  PlatformEntity.swift
//  GameNet
//

#if os(iOS)
import AppIntents
import Foundation

struct PlatformEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Platform")
    static var defaultQuery = PlatformEntityQuery()

    var id: String
    var name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct PlatformEntityQuery: EntityStringQuery {
    func entities(for identifiers: [PlatformEntity.ID]) async throws -> [PlatformEntity] {
        let platforms = await CreateGameService.make().platforms()
        return platforms.compactMap { platform in
            guard let id = platform.id, identifiers.contains(id) else { return nil }
            return PlatformEntity(id: id, name: platform.name)
        }
    }

    func suggestedEntities() async throws -> [PlatformEntity] {
        await CreateGameService.make().platforms().compactMap { platform in
            guard let id = platform.id else { return nil }
            return PlatformEntity(id: id, name: platform.name)
        }
    }

    func entities(matching string: String) async throws -> [PlatformEntity] {
        await CreateGameService.make().matchingPlatforms(query: string).compactMap { platform in
            guard let id = platform.id else { return nil }
            return PlatformEntity(id: id, name: platform.name)
        }
    }
}
#endif
