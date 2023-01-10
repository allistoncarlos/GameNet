//
//  PlatformRepositoryTests.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 23/08/22.
//

import Factory
@testable import GameNet
import GameNet_Network
import XCTest

class PlatformRepositoryTests: XCTestCase {
    override func setUp() async throws {
        Container.Registrations.reset()
        Container.Scope.reset()

        MockPlatformRepository.reset()
    }

    func testPlatform_ValidData_ShouldFetchValidData() async {
        // Given
        RepositoryContainer.platformRepository.register(factory: { MockPlatformRepository() })

        // When
        let result = await RepositoryContainer.platformRepository().fetchData()

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 2)
    }

    func testPlatform_FetchByValidId_ShouldReturnValidData() async {
        // Given
        let platformId = "1"
        RepositoryContainer.platformRepository.register(factory: { MockPlatformRepository() })

        // When
        let result = await RepositoryContainer.platformRepository().fetchData(id: platformId)

        // Then
        XCTAssertNotNil(result)
    }

    func testPlatform_FetchByInvalidId_ShouldntReturnData() async {
        // Given
        let platformId = "3"
        RepositoryContainer.platformRepository.register(factory: { MockPlatformRepository() })

        // When
        let result = await RepositoryContainer.platformRepository().fetchData(id: platformId)

        // Then
        XCTAssertNil(result)
    }

    func testPlatform_SaveNewData_ShouldSave() async {
        // Given
        RepositoryContainer.platformRepository.register(factory: { MockPlatformRepository() })

        let platformName = "PlayStation 4"
        let repositoryContainer = RepositoryContainer.platformRepository()

        // When
        let result = await repositoryContainer.savePlatform(id: nil, platform: Platform(id: nil, name: platformName))

        // Then
        XCTAssertNotNil(result)

        if let id = result?.id {
            let fetchedPlatformResult = await repositoryContainer.fetchData(id: id)
            XCTAssertNotNil(fetchedPlatformResult)
        }
    }

    func testPlatform_SaveExistingData_ShouldSave() async {
        // Given
        RepositoryContainer.platformRepository.register(factory: { MockPlatformRepository() })

        let platformId = "1"
        let platformNewName = "Super Nintendo"
        let repositoryContainer = RepositoryContainer.platformRepository()
        let existingPlatform = await repositoryContainer.fetchData(id: platformId)

        guard let existingPlatform = existingPlatform else {
            XCTFail()
            return
        }

        // When
        let editedExistingPlatform = Platform(id: existingPlatform.id, name: platformNewName)
        let result = await repositoryContainer.savePlatform(id: platformId, platform: editedExistingPlatform)

        // Then
        XCTAssertNotNil(result)

        if let id = result?.id {
            let fetchedPlatformResult = await repositoryContainer.fetchData(id: id)
            XCTAssertNotNil(fetchedPlatformResult)
            XCTAssertEqual(platformNewName, fetchedPlatformResult?.name)
        }
    }
}
