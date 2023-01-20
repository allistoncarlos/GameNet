//
//  ListRepositoryTests.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 11/01/23.
//

import Factory
@testable import GameNet
import GameNet_Network
import XCTest

class ListRepositoryTests: XCTestCase {
    override func setUp() async throws {
        Container.Registrations.reset()
        Container.Scope.reset()

        MockListRepository.reset()
    }

    func testList_ValidData_ShouldFetchValidData() async {
        // Given
        RepositoryContainer.listRepository.register(factory: { MockListRepository() })

        // When
        let result = await RepositoryContainer.listRepository().fetchData()

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 2)
    }

    func testList_FetchByValidId_ShouldReturnValidData() async {
        // Given
        let listId = "1"
        RepositoryContainer.listRepository.register(factory: { MockListRepository() })

        // When
        let result = await RepositoryContainer.listRepository().fetchData(id: listId)

        // Then
        XCTAssertNotNil(result)
    }

    func testList_FetchByInvalidId_ShouldntReturnData() async {
        // Given
        let listId = "3"
        RepositoryContainer.listRepository.register(factory: { MockListRepository() })

        // When
        let result = await RepositoryContainer.listRepository().fetchData(id: listId)

        // Then
        XCTAssertNil(result)
    }

    func testList_SaveNewData_ShouldSave() async {
        // Given
        RepositoryContainer.listRepository.register(factory: { MockListRepository() })

        let listName = "Jogos à Comprar"
        let repositoryContainer = RepositoryContainer.listRepository()

        // When
        let result = await repositoryContainer.saveList(id: nil, list: List(id: nil, name: listName))

        // Then
        XCTAssertNotNil(result)

        if let id = result?.id {
            let fetchedListResult = await repositoryContainer.fetchData(id: id)
            XCTAssertNotNil(fetchedListResult)
        }
    }

    func testList_SaveExistingData_ShouldSave() async {
        // Given
        RepositoryContainer.listRepository.register(factory: { MockListRepository() })

        let listId = "1"
        let listNewName = "Próximos Jogos"
        let repositoryContainer = RepositoryContainer.listRepository()
        let existingList = await repositoryContainer.fetchData(id: listId)

        guard let existingList = existingList else {
            XCTFail()
            return
        }

        // When
        let editedExistingList = List(id: existingList.id, name: listNewName)
        let result = await repositoryContainer.saveList(id: listId, list: editedExistingList)

        // Then
        XCTAssertNotNil(result)

        if let id = result?.id {
            let fetchedListResult = await repositoryContainer.fetchData(id: id)
            XCTAssertNotNil(fetchedListResult)
            XCTAssertEqual(listNewName, fetchedListResult?.name)
        }
    }
}
