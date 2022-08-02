//
//  LoginRepositoryTests.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 02/08/22.
//

import Factory
@testable import GameNet
import XCTest

class LoginRepositoryTests: XCTestCase {
    var repository = RepositoryContainer.loginRepository()

    override func setUp() async throws {
        Container.Registrations.reset()
        Container.Scope.reset()
    }

    func testLogin_ValidData_ShouldReturnAccessToken() async {
        // Arrange
        let expectedAccessToken = "123"
        let login = Login(username: "teste", password: "teste")
        RepositoryContainer.loginRepository.register(factory: { MockLoginRepository() })

        // Act
        let result = await RepositoryContainer.loginRepository().login(login: login)

        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.accessToken, expectedAccessToken)
    }

    func testLogin_InvalidData_ShouldReturnNil() async {
        // Arrange
        let login = Login(username: "teste1", password: "teste")
        RepositoryContainer.loginRepository.register(factory: { MockLoginRepository() })

        // Act
        let result = await RepositoryContainer.loginRepository().login(login: login)

        // Assert
        XCTAssertNil(result)
        XCTAssertEqual(result?.accessToken, nil)
    }
}
