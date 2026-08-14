//
//  AddGameToListService.swift
//  GameNet
//

import Factory
import Foundation

enum AddGameToListResult: Equatable {
    case added(gameName: String, listName: String)
    case alreadyInList(gameName: String, listName: String)
    case listNotFound
    case gameNotFound
    case notLoggedIn
    case saveFailed
}

struct AddGameToListService {
    let listRepository: ListRepositoryProtocol
    let gameRepository: GameRepositoryProtocol
    let tokenDataSource: TokenDataSourceProtocol

    static func make() -> AddGameToListService {
        AddGameToListService(
            listRepository: Container.shared.listRepository(),
            gameRepository: Container.shared.gameRepository(),
            tokenDataSource: Container.shared.tokenDataSource()
        )
    }

    func lists() async -> [List] {
        await listRepository.fetchData(cache: true) ?? []
    }

    func searchGames(matching query: String) async -> [Game] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let paged = await gameRepository.fetchData(
            search: trimmed,
            page: 0,
            pageSize: GameNetApp.pageSize
        )

        let results = paged?.result ?? []
        let needle = trimmed.lowercased()

        return results.filter { $0.name.lowercased().contains(needle) }
    }

    func game(id: String) async -> GameDetail? {
        await gameRepository.fetchData(id: id)
    }

    func suggestedGames() async -> [Game] {
        let paged = await gameRepository.fetchData(
            search: nil,
            page: 0,
            pageSize: GameNetApp.pageSize
        )

        return paged?.result ?? []
    }

    func add(gameId: String, listId: String) async -> AddGameToListResult {
        guard tokenDataSource.hasValidToken() else {
            return .notLoggedIn
        }

        guard let listGame = await listRepository.fetchData(id: listId, cache: false) else {
            return .listNotFound
        }

        guard let game = await gameRepository.fetchData(id: gameId),
              let userGameId = game.id else {
            return .gameNotFound
        }

        var games = listGame.games ?? []
        let alreadyInList = games.contains { item in
            item.userGameId == userGameId
        }

        if alreadyInList {
            return .alreadyInList(gameName: game.name, listName: listGame.name)
        }

        let listItem = ListItem(
            id: userGameId,
            name: game.name,
            platform: game.platform,
            userGameId: userGameId,
            year: nil,
            boughtDate: nil,
            value: nil,
            start: nil,
            finish: nil,
            cover: game.cover,
            order: games.count,
            comment: nil
        )

        games.append(listItem)

        let updated = ListGame(id: listGame.id, name: listGame.name, games: games)
        let saved = await listRepository.saveList(
            id: listGame.id,
            userId: tokenDataSource.id,
            list: updated
        )

        guard saved != nil else {
            return .saveFailed
        }

        return .added(gameName: game.name, listName: listGame.name)
    }
}
