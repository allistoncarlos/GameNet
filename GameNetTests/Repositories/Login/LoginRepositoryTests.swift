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
    override func setUp() async throws {
        Container.Registrations.reset()
        Container.Scope.reset()
    }

    func testLogin_ValidData_ShouldReturnAccessToken() async {
        // Given
        let expectedAccessToken = "123"
        let login = Login(username: "teste", password: "teste")
        RepositoryContainer.loginRepository.register(factory: { MockLoginRepository() })

        // When
        let result = await RepositoryContainer.loginRepository().login(login: login)

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.accessToken, expectedAccessToken)
    }

    func testLogin_InvalidData_ShouldReturnNil() async {
        // Given
        let login = Login(username: "teste1", password: "teste")
        RepositoryContainer.loginRepository.register(factory: { MockLoginRepository() })

        // When
        let result = await RepositoryContainer.loginRepository().login(login: login)

        // Then
        XCTAssertNil(result)
        XCTAssertEqual(result?.accessToken, nil)
    }
}
