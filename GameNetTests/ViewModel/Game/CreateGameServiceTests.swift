//
//  CreateGameServiceTests.swift
//  GameNetTests
//

import Factory
@testable import GameNet
import XCTest

final class CreateGameServiceTests: XCTestCase {
    override func setUp() async throws {
        Container.shared.reset()
        MockGameRepository.reset()
        MockPlatformRepository.reset()
        MockTheGamesDBRepository.reset()
        MockPlatformRepository.platformsOverride = [
            Platform(id: "3", name: "NES (Emulador)"),
            Platform(id: "7", name: "Nintendo Switch"),
            Platform(id: "10", name: "Nintendo Switch (Mega Drive)")
        ]
    }

    override func tearDown() async throws {
        MockPlatformRepository.platformsOverride = nil
        MockGameRepository.reset()
        MockTheGamesDBRepository.reset()
    }

    func testCreate_SavesDigitalWithoutOwnedOriginalAndZeroPrice() async {
        let service = makeService()
        let platform = Platform(id: "3", name: "NES (Emulador)")

        let result = await service.create(name: "Little Samson", platform: platform)

        XCTAssertEqual(
            result,
            .created(gameName: "Little Samson", platformName: "NES (Emulador)")
        )
        XCTAssertEqual(MockGameRepository.lastSavedGame?.name, "Little Samson")
        XCTAssertEqual(MockGameRepository.lastSavedGame?.platformId, "3")
        XCTAssertEqual(MockGameRepository.lastSavedUserGame?.price, 0)
        XCTAssertEqual(MockGameRepository.lastSavedUserGame?.have, false)
        XCTAssertEqual(MockGameRepository.lastSavedUserGame?.original, false)
        XCTAssertEqual(MockGameRepository.lastSavedUserGame?.digital, true)
    }

    func testCreate_WhenLoggedOut_ReturnsNotLoggedIn() async {
        let service = makeService(token: StubTokenDataSource(isValid: false))
        let platform = Platform(id: "3", name: "NES (Emulador)")

        let result = await service.create(name: "Little Samson", platform: platform)

        XCTAssertEqual(result, .notLoggedIn)
    }

    private func makeService(
        token: StubTokenDataSource = StubTokenDataSource()
    ) -> CreateGameService {
        CreateGameService(
            platformRepository: MockPlatformRepository(),
            gameRepository: MockGameRepository(),
            catalogRepository: MockTheGamesDBRepository(),
            tokenDataSource: token
        )
    }
}

private struct StubTokenDataSource: TokenDataSourceProtocol {
    var id: String? = "user-1"
    var accessToken: String? = "token"
    var refreshToken: String? = "refresh"
    var expiresIn: Date? = Date().addingTimeInterval(3600)
    var isValid = true

    func save(login: Login) {}
    func save(id: String?, accessToken: String, refreshToken: String, expiresIn: Date) {}
    func clear() {}
    func hasValidToken() -> Bool { isValid }
}
