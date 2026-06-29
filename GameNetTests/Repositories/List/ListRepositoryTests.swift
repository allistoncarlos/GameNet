//
//  ListRepositoryTests.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 11/01/23.
//

import Factory
@testable import GameNet
import XCTest

class ListRepositoryTests: XCTestCase {
    override func setUp() async throws {
        Container.shared.reset()

        MockListRepository.reset()
    }

    func testList_ValidData_ShouldFetchValidData() async {
        // Given
        Container.shared.listRepository.register(factory: { MockListRepository() })

        // When
        let result = await Container.shared.listRepository().fetchData(cache: false)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 2)
    }

    func testList_FetchByValidId_ShouldReturnValidData() async {
        // Given
        let listId = "1"
        Container.shared.listRepository.register(factory: { MockListRepository() })

        // When
        let result = await Container.shared.listRepository().fetchData(id: listId)

        // Then
        XCTAssertNotNil(result)
    }

    func testList_FetchByInvalidId_ShouldntReturnData() async {
        // Given
        let listId = "3"
        Container.shared.listRepository.register(factory: { MockListRepository() })

        // When
        let result = await Container.shared.listRepository().fetchData(id: listId)

        // Then
        XCTAssertNil(result)
    }

    func testList_SaveNewDataWithoutGames_ShouldSave() async {
        // Given
        Container.shared.listRepository.register(factory: { MockListRepository() })

        let userId = "123"
        let listName = "Jogos à Comprar"
        let repositoryContainer = Container.shared.listRepository()

        // When
        let result = await repositoryContainer.saveList(
            id: nil,
            userId: userId,
            list: ListGame(
                id: nil,
                name: listName,
                games: nil
            )
        )

        // Then
        XCTAssertNotNil(result)

        if let id = result?.id {
            let fetchedListResult = await repositoryContainer.fetchData(id: id)
            XCTAssertNotNil(fetchedListResult)
        }
    }

    func testList_SaveExistingData_ShouldSave() async {
        // Given
        Container.shared.listRepository.register(factory: { MockListRepository() })

        let userId = "123"
        let listId = "1"
        let listNewName = "Próximos Jogos"
        let repositoryContainer = Container.shared.listRepository()
        let existingList = await repositoryContainer.fetchData(id: listId)

        guard let existingList = existingList else {
            XCTFail()
            return
        }

        // When
        let editedExistingList = ListGame(
            id: existingList.id,
            name: listNewName,
            games: nil
        )
        let result = await repositoryContainer.saveList(
            id: listId,
            userId: userId,
            list: editedExistingList
        )

        // Then
        XCTAssertNotNil(result)

        if let id = result?.id {
            let fetchedListResult = await repositoryContainer.fetchData(id: id)
            XCTAssertNotNil(fetchedListResult)
            XCTAssertEqual(listNewName, fetchedListResult?.name)
        }
    }
}
