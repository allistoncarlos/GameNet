//
//  DashboardDataSourceTests.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 22/08/22.
//

import Factory
@testable import GameNet
import XCTest

class DashboardDataSourceTests: XCTestCase {
    override func setUp() async throws {
        Container.shared.reset()
    }

    func testDashboard_FetchData_ShouldReturnValidData() async {
        // Given
        Container.shared.dashboardDataSource.register(factory: { MockDashboardDataSource() })

        // When
        let result = await Container.shared.dashboardDataSource().fetchData()

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.totalGames, 500)
    }
}
