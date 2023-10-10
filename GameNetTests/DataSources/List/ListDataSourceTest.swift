//
//  ListDataSourceTest.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 11/01/23.
//

import Factory
@testable import GameNet
import GameNet_Network
import XCTest

class ListDataSourceTests: XCTestCase {
    override func setUp() async throws {
        Container.Registrations.reset()
        Container.Scope.reset()

        MockListDataSource.reset()
    }

    func testList_FetchData_ShouldReturnValidData() async {
        // Given
        DataSourceContainer.listDataSource.register(factory: { MockListDataSource() })

        // When
        let result = await DataSourceContainer.listDataSource().fetchData()

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 2)
    }

    func testList_FetchByValidId_ShouldReturnValidData() async {
        // Given
        let listId = "1"
        DataSourceContainer.listDataSource.register(factory: { MockListDataSource() })

        // When
        let result = await DataSourceContainer.listDataSource().fetchData(id: listId)

        // Then
        XCTAssertNotNil(result)
    }

    func testList_FetchByInvalidId_ShouldntReturnData() async {
        // Given
        let listId = "3"
        DataSourceContainer.listDataSource.register(factory: { MockListDataSource() })

        // When
        let result = await DataSourceContainer.listDataSource().fetchData(id: listId)

        // Then
        XCTAssertNil(result)
    }

    func testList_SaveNewDataWithoutGames_ShouldSave() async {
        // Given
        DataSourceContainer.listDataSource.register(factory: { MockListDataSource() })

        let userId = "123"
        let listName = "Jogos à Comprar"
        let dataSourceContainer = DataSourceContainer.listDataSource()

        // When
        let result = await dataSourceContainer.saveList(
            id: nil,
            userId: userId,
            list: ListGame(id: nil, name: listName, games: nil))

        // Then
        XCTAssertNotNil(result)

        if let id = result?.id {
            let fetchedListResult = await dataSourceContainer.fetchData(id: id)
            XCTAssertNotNil(fetchedListResult)
        }
    }

    func testList_SaveExistingData_ShouldSave() async {
        // Given
        DataSourceContainer.listDataSource.register(factory: { MockListDataSource() })

        let listId = "1"
        let userId = "123"
        let listNewName = "Próximos Jogos"
        let dataSourceContainer = DataSourceContainer.listDataSource()
        let existingList = await dataSourceContainer.fetchData(id: listId)

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
        let result = await dataSourceContainer.saveList(id: listId, userId: userId, list: editedExistingList)

        // Then
        XCTAssertNotNil(result)

        if let id = result?.id {
            let fetchedListResult = await DataSourceContainer.listDataSource().fetchData(id: id)
            XCTAssertNotNil(fetchedListResult)
            XCTAssertEqual(listNewName, fetchedListResult?.name)
        }
    }
}
