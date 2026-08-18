//
//  GamesViewModelTests.swift
//  GameNetTests
//

import Factory
@testable import GameNet
import XCTest

@MainActor
final class GamesViewModelTests: XCTestCase {

    override func setUp() async throws {
        Container.shared.reset()
        MockGameRepository.reset()
        MockPlatformRepository.reset()
        Container.shared.gameRepository.register { MockGameRepository() }
        Container.shared.platformRepository.register { MockPlatformRepository() }
    }

    func testFetchData_ListsOrigin_LoadsGamesForLookup() async {
        let viewModel = GamesViewModel()

        await viewModel.fetchData(origin: .lists, clear: true)

        XCTAssertEqual(viewModel.data.count, 4)
        XCTAssertEqual(viewModel.state, .success)
    }

    func testFetchData_ListsOriginSearch_ReturnsMatchingGames() async {
        let viewModel = GamesViewModel()

        await viewModel.fetchData(origin: .lists, search: "Zelda", clear: true)

        XCTAssertEqual(viewModel.searchedGames.count, 2)
        XCTAssertTrue(viewModel.searchedGames.allSatisfy { $0.name.localizedCaseInsensitiveContains("Zelda") })
        XCTAssertTrue(viewModel.data.isEmpty)
        XCTAssertEqual(viewModel.state, .success)
    }
}
