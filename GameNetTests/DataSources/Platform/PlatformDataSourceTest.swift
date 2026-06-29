//
//  PlatformDataSourceTest.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 23/08/22.
//

import Factory
@testable import GameNet
import XCTest

class PlatformDataSourceTests: XCTestCase {
    override func setUp() async throws {
        Container.shared.reset()

        MockPlatformDataSource.reset()
    }

    func testPlatform_FetchData_ShouldReturnValidData() async {
        // Given
        Container.shared.platformDataSource.register(factory: { MockPlatformDataSource() })

        // When
        let result = await Container.shared.platformDataSource().fetchData(cache: false)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 2)
    }

    func testPlatform_FetchByValidId_ShouldReturnValidData() async {
        // Given
        let platformId = "1"
        Container.shared.platformDataSource.register(factory: { MockPlatformDataSource() })

        // When
        let result = await Container.shared.platformDataSource().fetchData(id: platformId)

        // Then
        XCTAssertNotNil(result)
    }

    func testPlatform_FetchByInvalidId_ShouldntReturnData() async {
        // Given
        let platformId = "3"
        Container.shared.platformDataSource.register(factory: { MockPlatformDataSource() })

        // When
        let result = await Container.shared.platformDataSource().fetchData(id: platformId)

        // Then
        XCTAssertNil(result)
    }

    func testPlatform_SaveNewData_ShouldSave() async {
        // Given
        Container.shared.platformDataSource.register(factory: { MockPlatformDataSource() })

        let platformName = "PlayStation 4"
        let dataSourceContainer = Container.shared.platformDataSource()

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
        Container.shared.platformDataSource.register(factory: { MockPlatformDataSource() })

        let platformId = "1"
        let platformNewName = "Super Nintendo"
        let dataSourceContainer = Container.shared.platformDataSource()
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
            let fetchedPlatformResult = await Container.shared.platformDataSource().fetchData(id: id)
            XCTAssertNotNil(fetchedPlatformResult)
            XCTAssertEqual(platformNewName, fetchedPlatformResult?.name)
        }
    }
}
