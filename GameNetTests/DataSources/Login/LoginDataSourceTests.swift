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
    var repository = DataSourceContainer.loginDataSource()

    override func setUp() async throws {
        Container.Registrations.reset()
        Container.Scope.reset()
    }

    func testLogin_ValidData_ShouldReturnAccessToken() async {
        // Arrange
        let expectedAccessToken = "123"
        let login = LoginRequest(username: "teste", password: "teste")
        DataSourceContainer.loginDataSource.register(factory: { MockLoginDataSource() })

        // Act
        let result = await DataSourceContainer.loginDataSource().login(loginRequest: login)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.accessToken, expectedAccessToken)
    }

    func testLogin_InvalidData_ShouldReturnNil() async {
        // Arrange
        let login = LoginRequest(username: "teste1", password: "teste")
        DataSourceContainer.loginDataSource.register(factory: { MockLoginDataSource() })

        // Act
        let result = await DataSourceContainer.loginDataSource().login(loginRequest: login)

        // Assert
        XCTAssertNil(result)
        XCTAssertEqual(result?.accessToken, nil)
    }
}
