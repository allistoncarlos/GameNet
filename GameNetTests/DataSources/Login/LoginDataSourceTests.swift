//
//  LoginDataSourceTests.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 02/08/22.
//

import Factory
@testable import GameNet
import GameNet_Network
import XCTest

class LoginDataSourceTests: XCTestCase {
    override func setUp() async throws {
        Container.Registrations.reset()
        Container.Scope.reset()
    }

    func testLogin_ValidData_ShouldReturnAccessToken() async {
        // Given
        let expectedAccessToken = "123"
        let login = LoginRequest(username: "teste", password: "teste")
        DataSourceContainer.loginDataSource.register(factory: { MockLoginDataSource() })

        // When
        let result = await DataSourceContainer.loginDataSource().login(loginRequest: login)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.accessToken, expectedAccessToken)
    }

    func testLogin_InvalidData_ShouldReturnNil() async {
        // Given
        let login = LoginRequest(username: "teste1", password: "teste")
        DataSourceContainer.loginDataSource.register(factory: { MockLoginDataSource() })

        // When
        let result = await DataSourceContainer.loginDataSource().login(loginRequest: login)

        // Then
        XCTAssertNil(result)
        XCTAssertEqual(result?.accessToken, nil)
    }
}
