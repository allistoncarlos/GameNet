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
    override func setUp() async throws {
        Container.shared.reset()
    }

    func testDashboard_ValidData_ShouldValidData() async {
        // Given
        Container.shared.dashboardRepository.register(factory: { MockDashboardRepository() })

        // When
        let result = await Container.shared.dashboardRepository().fetchData()

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.totalGames, 500)
    }
}
