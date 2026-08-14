//
//  ListEntity.swift
//  GameNet
//

#if os(iOS)
import AppIntents
import Foundation

struct ListEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "List")
    static var defaultQuery = ListEntityQuery()

    var id: String
    var name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct ListEntityQuery: EntityStringQuery {
    func entities(for identifiers: [ListEntity.ID]) async throws -> [ListEntity] {
        let lists = await AddGameToListService.make().lists()
        return lists.compactMap { list in
            guard let id = list.id, identifiers.contains(id) else { return nil }
            return ListEntity(id: id, name: list.name)
        }
    }

    func suggestedEntities() async throws -> [ListEntity] {
        await AddGameToListService.make().lists().compactMap { list in
            guard let id = list.id else { return nil }
            return ListEntity(id: id, name: list.name)
        }
    }

    func entities(matching string: String) async throws -> [ListEntity] {
        let needle = string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !needle.isEmpty else { return try await suggestedEntities() }

        let lists = await AddGameToListService.make().lists()
        let mapped = lists.compactMap { list -> ListEntity? in
            guard let id = list.id else { return nil }
            return ListEntity(id: id, name: list.name)
        }

        let exact = mapped.filter { $0.name.lowercased() == needle }
        if !exact.isEmpty {
            return exact
        }

        return mapped.filter { $0.name.lowercased().contains(needle) }
    }
}
#endif
