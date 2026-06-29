//
//  DashboardViewModelTests.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 22/08/22.
//

import Combine
import Factory
@testable import GameNet
import GameNet_Keychain
import XCTest

@MainActor
class DashboardViewModelTests: XCTestCase {

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

    func testDashboard_ValidData_ShouldReturnData() async {
        // Given
        let dashboardLoadedExpectation = expectation(description: "Dashboard Loaded")
        let fakeJSONResponse = mock.fakeSuccessDashboardResponse

        stubRequests.stubJSONResponse(jsonObject: fakeJSONResponse, header: nil, statusCode: 200, absoluteStringWord: "gamenet.azurewebsites.net")

        RepositoryContainer.dashboardRepository.register(factory: { MockDashboardRepository() })

        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                // Then
                if case .success = state {
                    dashboardLoadedExpectation.fulfill()

                    XCTAssertNotNil(self?.viewModel.dashboard)
                }
            }.store(in: &cancellables)

        // When
        await viewModel.fetchData()
        await fulfillment(of: [dashboardLoadedExpectation], timeout: 30)
    }

    func testAnnualGameplayProgress_ShouldAccumulateMinutesByDay() throws {
        let formatter = ISO8601DateFormatter()
        let calendar = Calendar(identifier: .gregorian)

        let gameplaySessions = GameplaySessions(
            id: "2021",
            sessions: [
                GameplaySession(
                    id: "1",
                    userGameId: "game-1",
                    start: formatter.date(from: "2021-01-01T10:00:00Z")!,
                    finish: formatter.date(from: "2021-01-01T11:00:00Z")!,
                    gameName: "Game 1",
                    gameCover: "",
                    platformName: "Platform",
                    totalGameplayTime: "01:00"
                ),
                GameplaySession(
                    id: "2",
                    userGameId: "game-1",
                    start: formatter.date(from: "2021-01-02T12:00:00Z")!,
                    finish: formatter.date(from: "2021-01-02T12:30:00Z")!,
                    gameName: "Game 1",
                    gameCover: "",
                    platformName: "Platform",
                    totalGameplayTime: "00:30"
                ),
            ],
            totalGameplayTime: "01:30",
            averageGameplayTime: "00:45"
        )

        let series = DashboardViewModel.makeAnnualGameplayProgress(
            gameplaySessionsByYear: [2021: gameplaySessions],
            currentDate: formatter.date(from: "2026-01-03T12:00:00Z")!,
            calendar: calendar
        )

        let year2021 = try XCTUnwrap(series.first(where: { $0.year == 2021 }))

        XCTAssertEqual(series.first?.year, 2021)
        XCTAssertEqual(year2021.points.count, 3)
        XCTAssertEqual(year2021.points[0].cumulativeMinutes, 60, accuracy: 0.001)
        XCTAssertEqual(year2021.points[1].cumulativeMinutes, 90, accuracy: 0.001)
        XCTAssertEqual(year2021.points[2].cumulativeMinutes, 90, accuracy: 0.001)
        XCTAssertEqual(year2021.totalMinutes, 90, accuracy: 0.001)
        XCTAssertEqual(series.last?.year, 2026)
    }

    // MARK: Private

    private let mock = DashboardResponseMock()
    private let stubRequests = StubRequests()
    private var viewModel = DashboardViewModel()
    private var cancellables: Set<AnyCancellable>!
}
