//
//  AddGameToListServiceTests.swift
//  GameNetTests
//

import Factory
@testable import GameNet
import XCTest

private struct StubTokenDataSource: TokenDataSourceProtocol {
    var id: String? = "user-1"
    var accessToken: String? = "token"
    var refreshToken: String? = "refresh"
    var expiresIn: Date? = Date().addingTimeInterval(3600)
    var isValid = true

    func save(login: Login) {}

    func save(id: String?, accessToken: String, refreshToken: String, expiresIn: Date) {}

    func clear() {}

    func hasValidToken() -> Bool { isValid }
}

final class AddGameToListServiceTests: XCTestCase {
    override func setUp() async throws {
        Container.shared.reset()
        MockListRepository.reset()
        MockGameRepository.reset()
    }

    func testSearchGames_MatchingName_ReturnsOnlyMatchingGames() async {
        let service = makeService()

        let result = await service.searchGames(matching: "Zelda")

        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.name.localizedCaseInsensitiveContains("Zelda") })
    }

    func testSearchGames_SingleMatch_ReturnsOneGame() async {
        let service = makeService()

        let result = await service.searchGames(matching: "Horizon")

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Horizon: Forbidden West")
    }

    func testAdd_WhenLoggedOut_ReturnsNotLoggedIn() async {
        let service = makeService(token: StubTokenDataSource(isValid: false))

        let result = await service.add(gameId: "1", listId: "1")

        XCTAssertEqual(result, .notLoggedIn)
    }

    func testAdd_InvalidList_ReturnsListNotFound() async {
        let service = makeService()

        let result = await service.add(gameId: "1", listId: "missing")

        XCTAssertEqual(result, .listNotFound)
    }

    func testAdd_NewGame_AppendsToList() async {
        let service = makeService()

        let result = await service.add(gameId: "1", listId: "1")

        XCTAssertEqual(
            result,
            .added(
                gameName: "The Legend of Zelda: Tears of the Kingdom",
                listName: "Lista Padrão"
            )
        )

        let list = await Container.shared.listRepository().fetchData(id: "1")
        XCTAssertEqual(list?.games?.count, 6)
        XCTAssertEqual(list?.games?.last?.userGameId, "1")
    }

    func testAdd_GameAlreadyInList_DoesNotDuplicate() async {
        let service = makeService()

        _ = await service.add(gameId: "1", listId: "1")
        let result = await service.add(gameId: "1", listId: "1")

        XCTAssertEqual(
            result,
            .alreadyInList(
                gameName: "The Legend of Zelda: Tears of the Kingdom",
                listName: "Lista Padrão"
            )
        )

        let list = await Container.shared.listRepository().fetchData(id: "1")
        XCTAssertEqual(list?.games?.count, 6)
    }

    private func makeService(token: StubTokenDataSource = StubTokenDataSource()) -> AddGameToListService {
        Container.shared.listRepository.register { MockListRepository() }
        Container.shared.gameRepository.register { MockGameRepository() }

        return AddGameToListService(
            listRepository: Container.shared.listRepository(),
            gameRepository: Container.shared.gameRepository(),
            tokenDataSource: token
        )
    }
}
