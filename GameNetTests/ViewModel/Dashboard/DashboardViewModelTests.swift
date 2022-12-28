//
//  DashboardViewModelTests.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 22/08/22.
//

import Combine
import Factory
@testable import GameNet
import GameNet_Keychain
import XCTest

class DashboardViewModelTests: XCTestCase {
    // MARK: Internal

    override func setUp() async throws {
        Container.Registrations.reset()
        Container.Scope.reset()
    }

    override func tearDown() {
        super.tearDown()

        KeychainDataSource.clear()
    }

    func testDashboard_ValidData_ShouldReturnData() async {
        // Given
        let dashboardLoadedExpectation = expectation(description: "Dashboard Loaded")
        let fakeJSONResponse = mock.fakeSuccessDashboardResponse

        stubRequests.stubJSONResponse(jsonObject: fakeJSONResponse, header: nil, statusCode: 200, absoluteStringWord: "gamenet.azurewebsites.net")

        RepositoryContainer.dashboardRepository.register(factory: { MockDashboardRepository() })

        let cancellable = viewModel.$state
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] state in
                // Then
                if self?.viewModel.state == .success {
                    dashboardLoadedExpectation.fulfill()

                    XCTAssertNotNil(self?.viewModel.dashboard)
                }
            })

        // When
        await viewModel.fetchData()
        await waitForExpectations(timeout: 10)

        cancellable.cancel()
    }

    // MARK: Private

    private let mock = DashboardResponseMock()
    private let stubRequests = StubRequests()
    private var viewModel = DashboardViewModel()
}
