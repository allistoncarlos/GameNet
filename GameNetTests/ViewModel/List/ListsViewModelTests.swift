//
//  ListsViewModelTests.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 11/01/23.
//

import Combine
import Factory
@testable import GameNet
import GameNet_Keychain
import XCTest

@MainActor
class ListsViewModelTests: XCTestCase {

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

    func testLists_ValidData_ShouldReturnAccessToken() async {
        // Given
        let listsLoadedExpectation = expectation(description: "Lists Loaded")
        let fakeJSONResponse = mock.fakeSuccessListsResponse

        stubRequests.stubJSONResponse(jsonObject: fakeJSONResponse, header: nil, statusCode: 200, absoluteStringWord: "gamenet.azurewebsites.net")

        RepositoryContainer.listRepository.register(factory: { MockListRepository() })

        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { state in
                // Then
                if case let .success(lists) = state {
                    listsLoadedExpectation.fulfill()

                    XCTAssertNotNil(lists)
                }
            }.store(in: &cancellables)

        // When
        await viewModel.fetchData()
        waitForExpectations(timeout: 10)
    }

    // MARK: Private

    private let mock = ListResponseMock()
    private let stubRequests = StubRequests()
    private var viewModel = ListsViewModel()
    private var cancellables: Set<AnyCancellable>!
}
