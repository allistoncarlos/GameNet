//
//  EditListViewModelTests.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 11/01/23.
//

import Combine
import Factory
@testable import GameNet
import GameNet_Keychain
import GameNet_Network
import XCTest

@MainActor
class EditListViewModelTests: XCTestCase {

    // MARK: Internal

    override func setUpWithError() throws {
        Container.Registrations.reset()
        Container.Scope.reset()

        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        super.tearDown()

        KeychainDataSource.clear()
        cancellables.forEach { $0.cancel() }
    }

    func testEditList_NewValidData_ShouldSaveNewList() async {
        // Given
        let matchSavedListExpectation = expectation(description: "List are equal")
        let stateExpectation = expectation(description: "Success UIState")

        let expectedId: String? = "3"
        let name = "Teste"

        let fakeJSONResponse = mock.fakeSuccessSaveListResponse

        stubRequests.stubJSONResponse(
            jsonObject: fakeJSONResponse,
            header: nil,
            statusCode: 201,
            absoluteStringWord: "gamenet.azurewebsites.net"
        )

        RepositoryContainer.listRepository.register(factory: { MockListRepository() })

        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { state in
                if case let .success(list) = state {
                    // Then
                    XCTAssertNotNil(list)
                    XCTAssertEqual(expectedId, list.id)
                    XCTAssertEqual(name, list.name)

                    matchSavedListExpectation.fulfill()
                    stateExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.list.name = name
        await viewModel.save()
        await fulfillment(of: [matchSavedListExpectation, stateExpectation], timeout: 30)
    }

    // MARK: Private

    private var cancellables = Set<AnyCancellable>()
    private let mock = EditListResponseMock()
    private let stubRequests = StubRequests()
    private var viewModel = EditListViewModel(list: List(id: nil, name: String()))
}
