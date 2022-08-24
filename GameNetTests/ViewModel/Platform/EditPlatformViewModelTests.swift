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
import XCTest

class EditPlatformViewModelTests: XCTestCase {
    override func setUp() async throws {
        Container.Registrations.reset()
        Container.Scope.reset()
    }

    override func tearDown() {
        super.tearDown()

        KeychainDataSource.clear()
    }

    func testEditPlatform_NewValidData_ShouldSaveNewPlatform() async {
        // Given

        // When

        // Then
    }
}
