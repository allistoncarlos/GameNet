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

class LoginViewModelTests: XCTestCase {
    // MARK: Internal

    override func setUp() async throws {
        Container.Registrations.reset()
        Container.Scope.reset()
    }

    override func tearDown() {
        super.tearDown()

        KeychainDataSource.clear()
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

        let cancellable = viewModel.$state
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] state in
                // Then
                if self?.viewModel.state == .success {
                    matchAccessTokenExpectation.fulfill()

                    let resultAccessToken = KeychainDataSource.accessToken.get()
                    XCTAssertNotNil(resultAccessToken)
                    XCTAssertEqual(expectedAccessToken, resultAccessToken)
                }
            })

        // When
        await viewModel.login(username: username, password: password)
        await waitForExpectations(timeout: 10)

        cancellable.cancel()
    }

    func testLogin_InvalidData_ShouldNotReturnAccessToken() async {
        // Given
        let nilAccessTokenExpectation = expectation(description: "AccessToken is nil")

        let fakeJSONResponse = mock.fakeFailureLoginResponse

        stubRequests.stubJSONResponse(jsonObject: fakeJSONResponse, header: nil, statusCode: 400, absoluteStringWord: "gamenet.azurewebsites.net")

        let username = "teste"
        let password = "teste"
        let expectedError = "Usuário ou senha inválidos"
        RepositoryContainer.loginRepository.register(factory: { MockLoginRepository() })

        let cancellable = viewModel.$state
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Received finished")
                case let .failure(error):
                    print(error)
                }
            } receiveValue: { [weak self] state in
                // Then
                if case let .error(error) = self?.viewModel.state {
                    nilAccessTokenExpectation.fulfill()

                    let resultAccessToken = KeychainDataSource.accessToken.get()
                    XCTAssertNil(resultAccessToken)
                    XCTAssertEqual(error, expectedError)
                }
            }

        // When
        await viewModel.login(username: username, password: password)
        await waitForExpectations(timeout: 10)

        cancellable.cancel()
    }

    // MARK: Private

    private let mock = LoginResponseMock()
    private let stubRequests = StubRequests()
    private var viewModel = LoginViewModel()
}
