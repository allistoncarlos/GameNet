//
//  WidgetSharedPlayingGameTests.swift
//  GameNetTests
//

@testable import GameNet
import XCTest

final class WidgetSharedPlayingGameTests: XCTestCase {

    func testPreferredForWidget_PicksMostRecentlyFinishedSession_OverOlderOpenSession() {
        let olderOpen = game(
            id: "old-open",
            start: date("2026-07-10T21:00:00Z"),
            finish: nil
        )
        let recentlyFinished = game(
            id: "recent-finished",
            start: date("2026-09-04T18:00:00Z"),
            finish: date("2026-09-04T19:30:00Z")
        )

        let preferred = WidgetSharedPlayingGame.preferredForWidget(from: [olderOpen, recentlyFinished])

        XCTAssertEqual(preferred?.id, "recent-finished")
    }

    func testPreferredForWidget_PicksRecentlyStartedSession_OverOlderFinishedSession() {
        let olderFinished = game(
            id: "old-finished",
            start: date("2026-09-03T10:00:00Z"),
            finish: date("2026-09-03T11:00:00Z")
        )
        let currentlyPlaying = game(
            id: "playing-now",
            start: date("2026-09-04T18:10:00Z"),
            finish: nil
        )

        let preferred = WidgetSharedPlayingGame.preferredForWidget(from: [olderFinished, currentlyPlaying])

        XCTAssertEqual(preferred?.id, "playing-now")
    }

    func testPreferredForWidget_EmptyList_ReturnsNil() {
        XCTAssertNil(WidgetSharedPlayingGame.preferredForWidget(from: []))
    }

    func testPreferredForWidget_GamesWithoutSession_LoseToGamesWithSession() {
        let neverPlayed = game(id: "never", start: nil, finish: nil)
        let lastPlayed = game(
            id: "played",
            start: date("2026-08-01T12:00:00Z"),
            finish: date("2026-08-01T13:00:00Z")
        )

        let preferred = WidgetSharedPlayingGame.preferredForWidget(from: [neverPlayed, lastPlayed])

        XCTAssertEqual(preferred?.id, "played")
    }

    func testShouldKeepLocalActive_WhenLocalStartIsStale_ReturnsFalse() {
        let localStaleOpen = game(
            id: "stale",
            start: date("2026-07-10T21:00:00Z"),
            finish: nil
        )
        let remoteRecent = game(
            id: "recent",
            start: date("2026-09-04T18:00:00Z"),
            finish: date("2026-09-04T19:00:00Z")
        )

        XCTAssertFalse(
            WidgetSharedPlayingGame.shouldKeepLocalActive(localStaleOpen, over: [remoteRecent])
        )
    }

    func testShouldKeepLocalActive_WhenLocalStartIsNewer_ReturnsTrue() {
        let localJustStarted = game(
            id: "just-started",
            start: date("2026-09-04T20:00:00Z"),
            finish: nil
        )
        let remoteOlder = game(
            id: "older",
            start: date("2026-09-04T10:00:00Z"),
            finish: date("2026-09-04T11:00:00Z")
        )

        XCTAssertTrue(
            WidgetSharedPlayingGame.shouldKeepLocalActive(localJustStarted, over: [remoteOlder])
        )
    }

    // MARK: - Helpers

    private func game(
        id: String,
        start: Date?,
        finish: Date?
    ) -> WidgetSharedPlayingGame {
        WidgetSharedPlayingGame(
            id: id,
            name: id,
            platform: "Switch",
            coverURL: "",
            latestSessionId: start == nil ? nil : "session-\(id)",
            latestStart: start,
            latestFinish: finish
        )
    }

    private func date(_ iso: String) -> Date {
        ISO8601DateFormatter().date(from: iso)!
    }
}
