//
//  LoginViewModelTests.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 02/08/22.
//

import Combine
import Factory
@testable import GameNet
import GameNet_Keychain
import XCTest

@MainActor
class LoginViewModelTests: XCTestCase {

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

    func testLogin_ValidData_ShouldReturnAccessToken() async {
        // Given
        let matchAccessTokenExpectation = expectation(description: "AccessToken is equal")

        let fakeJSONResponse = mock.fakeSuccessLoginResponse

        stubRequests.stubJSONResponse(jsonObject: fakeJSONResponse, header: nil, statusCode: 200, absoluteStringWord: "gamenet.azurewebsites.net")

        let expectedAccessToken = "accessToken123"
        let username = "teste"
        let password = "teste"
        RepositoryContainer.loginRepository.register(factory: { MockLoginRepository() })

        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { state in
                // Then
                if case .success = state {
                    matchAccessTokenExpectation.fulfill()

                    let resultAccessToken = KeychainDataSource.accessToken.get()
                    XCTAssertNotNil(resultAccessToken)
                    XCTAssertEqual(expectedAccessToken, resultAccessToken)
                }
            }.store(in: &cancellables)

        // When
        await viewModel.login(username: username, password: password)
        waitForExpectations(timeout: 10)
    }

    func testLogin_InvalidData_ShouldNotReturnAccessToken() async {
        // Given
        let nilAccessTokenExpectation = expectation(description: "AccessToken is nil")

        let fakeJSONResponse = mock.fakeFailureLoginResponse

        stubRequests.stubJSONResponse(jsonObject: fakeJSONResponse, header: nil, statusCode: 400, absoluteStringWord: "gamenet.azurewebsites.net")

        let username = "teste"
        let password = "teste"
        let expectedError: LoginError = .invalidUsernameOrPassword
        RepositoryContainer.loginRepository.register(factory: { MockLoginRepository() })

        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                if case let .error(error) = self?.viewModel.state {
                    nilAccessTokenExpectation.fulfill()

                    XCTAssertEqual(error, .invalidUsernameOrPassword)
                    
                    let resultAccessToken = KeychainDataSource.accessToken.get()
                    XCTAssertNil(resultAccessToken)
                    XCTAssertEqual(error, expectedError)
                }
            }.store(in: &cancellables)

        // When
        await viewModel.login(username: username, password: password)
        waitForExpectations(timeout: 10)
    }

    // MARK: Private

    private let mock = LoginResponseMock()
    private let stubRequests = StubRequests()
    private var viewModel = LoginViewModel()
    private var cancellables: Set<AnyCancellable>!
}
