//
//  PlatformDataSourceTest.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 23/08/22.
//

import Factory
@testable import GameNet
import GameNet_Network
import XCTest

class PlatformDataSourceTests: XCTestCase {
    override func setUp() async throws {
        Container.Registrations.reset()
        Container.Scope.reset()

        MockPlatformDataSource.reset()
    }

    func testPlatform_FetchData_ShouldReturnValidData() async {
        // Given
        DataSourceContainer.platformDataSource.register(factory: { MockPlatformDataSource() })

        // When
        let result = await DataSourceContainer.platformDataSource().fetchData(cache: false)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 2)
    }

    func testPlatform_FetchByValidId_ShouldReturnValidData() async {
        // Given
        let platformId = "1"
        DataSourceContainer.platformDataSource.register(factory: { MockPlatformDataSource() })

        // When
        let result = await DataSourceContainer.platformDataSource().fetchData(id: platformId)

        // Then
        XCTAssertNotNil(result)
    }

    func testPlatform_FetchByInvalidId_ShouldntReturnData() async {
        // Given
        let platformId = "3"
        DataSourceContainer.platformDataSource.register(factory: { MockPlatformDataSource() })

        // When
        let result = await DataSourceContainer.platformDataSource().fetchData(id: platformId)

        // Then
        XCTAssertNil(result)
    }

    func testPlatform_SaveNewData_ShouldSave() async {
        // Given
        DataSourceContainer.platformDataSource.register(factory: { MockPlatformDataSource() })

        let platformName = "PlayStation 4"
        let dataSourceContainer = DataSourceContainer.platformDataSource()

        // When
        let result = await dataSourceContainer.savePlatform(id: nil, platform: Platform(id: nil, name: platformName))

        // Then
        XCTAssertNotNil(result)

        if let id = result?.id {
            let fetchedPlatformResult = await dataSourceContainer.fetchData(id: id)
            XCTAssertNotNil(fetchedPlatformResult)
        }
    }

    func testPlatform_SaveExistingData_ShouldSave() async {
        // Given
        DataSourceContainer.platformDataSource.register(factory: { MockPlatformDataSource() })

        let platformId = "1"
        let platformNewName = "Super Nintendo"
        let dataSourceContainer = DataSourceContainer.platformDataSource()
        let existingPlatform = await dataSourceContainer.fetchData(id: platformId)

        guard let existingPlatform = existingPlatform else {
            XCTFail()
            return
        }

        // When
        let editedExistingPlatform = Platform(id: existingPlatform.id, name: platformNewName)
        let result = await dataSourceContainer.savePlatform(id: platformId, platform: editedExistingPlatform)

        // Then
        XCTAssertNotNil(result)

        if let id = result?.id {
            let fetchedPlatformResult = await DataSourceContainer.platformDataSource().fetchData(id: id)
            XCTAssertNotNil(fetchedPlatformResult)
            XCTAssertEqual(platformNewName, fetchedPlatformResult?.name)
        }
    }
}
