//
//  CatalogGameEntity.swift
//  GameNet
//

#if os(iOS)
import AppIntents
import Foundation

struct CatalogGameEntity: AppEntity, Hashable {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Catalog Game")
    static var defaultQuery = CatalogGameEntityQuery()

    var id: String
    var catalogId: Int
    var name: String
    var platformName: String?
    var released: String?

    var displayRepresentation: DisplayRepresentation {
        if let platformName, !platformName.isEmpty {
            let subtitle = released.flatMap { $0.isEmpty ? nil : $0 }.map { "\(platformName) · \($0)" } ?? platformName
            return DisplayRepresentation(title: "\(name)", subtitle: "\(subtitle)")
        }
        if let released, !released.isEmpty {
            return DisplayRepresentation(title: "\(name)", subtitle: "\(released)")
        }
        return DisplayRepresentation(title: "\(name)")
    }

    var asCatalogGame: TheGamesDBGame {
        TheGamesDBGame(
            id: catalogId,
            name: name,
            platformId: nil,
            platformName: platformName,
            released: released,
            boxartURL: nil
        )
    }
}

struct CatalogGameEntityQuery: EntityQuery {
    func entities(for identifiers: [CatalogGameEntity.ID]) async throws -> [CatalogGameEntity] {
        identifiers.compactMap { id in
            guard let catalogId = Int(id) else { return nil }
            return CatalogGameEntity(id: id, catalogId: catalogId, name: "Game \(id)", platformName: nil, released: nil)
        }
    }
}
#endif
