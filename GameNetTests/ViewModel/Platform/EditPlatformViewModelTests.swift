//
//  EditPlatformViewModelTests.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 24/08/22.
//

import Combine
import Factory
@testable import GameNet
import GameNet_Keychain
import GameNet_Network
import XCTest

class EditPlatformViewModelTests: XCTestCase {
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

    func testEditPlatform_NewValidData_ShouldSaveNewPlatform() async {
        // Given
        let matchSavedPlatformExpectation = expectation(description: "Platform are equal")
        let stateExpectation = expectation(description: "Success UIState")

        let expectedId: String? = "3"
        let name = "Teste"

        let fakeJSONResponse = mock.fakeSuccessSavePlatformResponse

        stubRequests.stubJSONResponse(
            jsonObject: fakeJSONResponse,
            header: nil,
            statusCode: 201,
            absoluteStringWord: "gamenet.azurewebsites.net"
        )

        RepositoryContainer.platformRepository.register(factory: { MockPlatformRepository() })

        viewModel.$platform
            .receive(on: RunLoop.main)
            .drop(while: { $0.id == nil })
            .sink(receiveValue: { platform in
                // Then
                XCTAssertNotNil(platform)
                XCTAssertEqual(expectedId, platform.id)
                XCTAssertEqual(name, platform.name)

                matchSavedPlatformExpectation.fulfill()
            })
            .store(in: &cancellables)

        viewModel.$state
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] state in
                // Then
                if self?.viewModel.state == .success {
                    stateExpectation.fulfill()
                }
            })
            .store(in: &cancellables)

        // When
        viewModel.platform.name = name
        await viewModel.save()
        await waitForExpectations(timeout: 10)
    }

    // MARK: Private

    private var cancellables = Set<AnyCancellable>()
    private let mock = EditPlatformResponseMock()
    private let stubRequests = StubRequests()
    private var viewModel = EditPlatformViewModel(platform: Platform(id: nil, name: String()))
}
