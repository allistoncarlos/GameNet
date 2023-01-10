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

@MainActor
class DashboardViewModelTests: XCTestCase {

    // MARK: Internal

    override func setUp() async throws {
        Container.Registrations.reset()
        Container.Scope.reset()

        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        super.tearDown()

        KeychainDataSource.clear()

        cancellables = nil
    }

    func testDashboard_ValidData_ShouldReturnData() async {
        // Given
        let dashboardLoadedExpectation = expectation(description: "Dashboard Loaded")
        let fakeJSONResponse = mock.fakeSuccessDashboardResponse

        stubRequests.stubJSONResponse(jsonObject: fakeJSONResponse, header: nil, statusCode: 200, absoluteStringWord: "gamenet.azurewebsites.net")

        RepositoryContainer.dashboardRepository.register(factory: { MockDashboardRepository() })

        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                // Then
                if case .success = state {
                    dashboardLoadedExpectation.fulfill()

                    XCTAssertNotNil(self?.viewModel.dashboard)
                }
            }.store(in: &cancellables)

        // When
        await viewModel.fetchData()
        waitForExpectations(timeout: 10)
    }

    // MARK: Private

    private let mock = DashboardResponseMock()
    private let stubRequests = StubRequests()
    private var viewModel = DashboardViewModel()
    private var cancellables: Set<AnyCancellable>!
}
