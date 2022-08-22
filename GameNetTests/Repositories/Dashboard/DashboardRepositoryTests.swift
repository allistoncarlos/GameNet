//
//  DashboardRepositoryTests.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 22/08/22.
//

import Factory
@testable import GameNet
import XCTest

class DashboardRepositoryTests: XCTestCase {
    var repository = RepositoryContainer.dashboardRepository()

    override func setUp() async throws {
        Container.Registrations.reset()
        Container.Scope.reset()
    }

    func testDashboard_ValidData_ShouldValidData() async {
        // Given
        RepositoryContainer.dashboardRepository.register(factory: { MockDashboardRepository() })

        // When
        let result = await RepositoryContainer.dashboardRepository().fetchData()

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.totalGames, 500)
    }
}
