//
//  DashboardDataSourceTests.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 22/08/22.
//

import Factory
@testable import GameNet
import GameNet_Network
import XCTest

class DashboardDataSourceTests: XCTestCase {
    var repository = DataSourceContainer.dashboardDataSource()

    override func setUp() async throws {
        Container.Registrations.reset()
        Container.Scope.reset()
    }

    func testDashboard_FetchData_ShouldReturnValidData() async {
        // Given
        DataSourceContainer.dashboardDataSource.register(factory: { MockDashboardDataSource() })

        // When
        let result = await DataSourceContainer.dashboardDataSource().fetchData()

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.totalGames, 500)
    }
}
