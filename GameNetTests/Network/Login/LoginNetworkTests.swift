//
//  LoginNetworkTests.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 02/08/22.
//

@testable import GameNet
import GameNet_Keychain
import GameNet_Network
import XCTest

final class LoginNetworkTests: XCTestCase {
    // MARK: - Properties

    let mock = LoginResponseMock()
    let stubRequests = StubRequests()

    // MARK: - SetUp/TearDown

    override func tearDown() {
        super.tearDown()
        KeychainDataSource.clear()
        URLCache.shared.removeAllCachedResponses()
    }

    // MARK: - Tests

    func testLogin_ValidParameters_ShouldReturnValidId() async {
        // Given
        let username = "username"
        let password = "password"

        let fakeJSONResponse = mock.fakeSuccessLoginResponse

        stubRequests.stubJSONResponse(jsonObject: fakeJSONResponse, header: nil, statusCode: 200, absoluteStringWord: "gamenet.azurewebsites.net")

        // When
        let result = await NetworkManager.shared
            .performRequest(
                responseType: LoginResponse.self,
                endpoint: .login(data: LoginRequest(username: username, password: password))
            )

        // Then
        XCTAssertNotNil(result)

        guard let result = result else { return }

        XCTAssertEqual(result.id, String(describing: fakeJSONResponse["id"]!))
    }

    func testLogin_WrongParameters_ShouldReturnNil() async {
        // Given
        let username = "username123"
        let password = "password123"

        let fakeJSONResponse = mock.fakeFailureLoginResponse

        stubRequests.stubJSONResponse(jsonObject: fakeJSONResponse, header: nil, statusCode: 200, absoluteStringWord: "gamenet.azurewebsites.net")

        // When
        let result = await NetworkManager.shared
            .performRequest(
                responseType: LoginResponse.self,
                endpoint: .login(data: LoginRequest(username: username, password: password))
            )

        // Then
        XCTAssertNil(result)
    }
}
