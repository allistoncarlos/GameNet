//
//  PlatformsViewModelTests.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 23/08/22.
//

import Combine
import Factory
@testable import GameNet
import GameNet_Keychain
import XCTest

class PlatformsViewModelTests: XCTestCase {
    // MARK: Internal

    override func setUp() async throws {
        Container.Registrations.reset()
        Container.Scope.reset()
    }

    override func tearDown() {
        super.tearDown()

        KeychainDataSource.clear()
    }

    func testPlatforms_ValidData_ShouldReturnAccessToken() async {
        // Given
        let platformsLoadedExpectation = expectation(description: "Platforms Loaded")
        let fakeJSONResponse = mock.fakeSuccessPlatformsResponse

        stubRequests.stubJSONResponse(jsonObject: fakeJSONResponse, header: nil, statusCode: 200, absoluteStringWord: "gamenet.azurewebsites.net")

        RepositoryContainer.platformRepository.register(factory: { MockPlatformRepository() })

        let cancellable = viewModel.$uiState
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] uiState in
                // Then
                if self?.viewModel.uiState == .success {
                    platformsLoadedExpectation.fulfill()

                    XCTAssertNotNil(self?.viewModel.platforms)
                }
            })

        // When
        await viewModel.fetchData()
        await waitForExpectations(timeout: 10)

        cancellable.cancel()
    }

    // MARK: Private

    private let mock = PlatformResponseMock()
    private let stubRequests = StubRequests()
    private var viewModel = PlatformsViewModel()
}
