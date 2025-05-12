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

@MainActor
class PlatformsViewModelTests: XCTestCase {

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

    func testPlatforms_ValidData_ShouldReturnAccessToken() async {
        // Given
        let platformsLoadedExpectation = expectation(description: "Platforms Loaded")
        let fakeJSONResponse = mock.fakeSuccessPlatformsResponse

        stubRequests.stubJSONResponse(jsonObject: fakeJSONResponse, header: nil, statusCode: 200, absoluteStringWord: "gamenet.azurewebsites.net")

        RepositoryContainer.platformRepository.register(factory: { MockPlatformRepository() })

        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { state in
                // Then
                if case let .success(platforms) = state {
                    platformsLoadedExpectation.fulfill()

                    XCTAssertNotNil(platforms)
                }
            }.store(in: &cancellables)

        // When
        await viewModel.fetchData()
        await fulfillment(of: [platformsLoadedExpectation], timeout: 30)
    }

    // MARK: Private

    private let mock = PlatformResponseMock()
    private let stubRequests = StubRequests()
    private var viewModel = PlatformsViewModel()
    private var cancellables: Set<AnyCancellable>!
}
