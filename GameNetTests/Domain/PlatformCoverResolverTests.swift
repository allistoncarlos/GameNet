//
//  PlatformCoverResolverTests.swift
//  GameNetTests
//

@testable import GameNet
import XCTest

final class PlatformCoverResolverTests: XCTestCase {
    private let platforms: [Platform] = [
        Platform(id: "1", name: "Master System (Emulador)"),
        Platform(id: "2", name: "Mega Drive (Emulador)"),
        Platform(id: "3", name: "NES (Emulador)"),
        Platform(id: "4", name: "Nintendo 3DS"),
        Platform(id: "5", name: "Nintendo 3DS (3D Classics)"),
        Platform(id: "6", name: "Nintendo 3DS (Virtual Console)"),
        Platform(id: "7", name: "Nintendo Switch"),
        Platform(id: "8", name: "Nintendo Switch (Emulador)"),
        Platform(id: "9", name: "Nintendo Switch (GameBoy Advance)"),
        Platform(id: "10", name: "Nintendo Switch (Mega Drive)"),
        Platform(id: "11", name: "Wii U (Virtual Console)")
    ]

    func testParse_IgnoredQualifier_UsesBaseForCover() {
        let parsed = PlatformCoverResolver.parse("NES (Emulador)")

        XCTAssertEqual(parsed.base, "NES")
        XCTAssertNil(parsed.qualifier)
        XCTAssertEqual(parsed.coverSearchName, "NES")
    }

    func testParse_VirtualConsole_UsesHostConsole() {
        let parsed = PlatformCoverResolver.parse("Wii U (Virtual Console)")

        XCTAssertNil(parsed.qualifier)
        XCTAssertEqual(parsed.coverSearchName, "Wii U")
    }

    func testParse_3DClassics_IsIgnored() {
        let parsed = PlatformCoverResolver.parse("Nintendo 3DS (3D Classics)")

        XCTAssertNil(parsed.qualifier)
        XCTAssertEqual(parsed.coverSearchName, "Nintendo 3DS")
    }

    func testParse_MeaningfulQualifier_UsesQualifierForCover() {
        let parsed = PlatformCoverResolver.parse("Nintendo Switch (Mega Drive)")

        XCTAssertEqual(parsed.qualifier, "Mega Drive")
        XCTAssertEqual(parsed.coverSearchName, "Mega Drive")
        XCTAssertEqual(parsed.base, "Nintendo Switch")
    }

    func testCandidates_NES_DoesNotAskChoice() {
        let result = PlatformCoverResolver.candidates(matching: "NES Emulador", in: platforms)

        XCTAssertEqual(result.map(\.name), ["NES (Emulador)"])
    }

    func testCandidates_MegaDrive_AsksBetweenHostAndSwitchService() {
        let result = PlatformCoverResolver.candidates(matching: "Mega Drive", in: platforms)

        XCTAssertEqual(
            result.map(\.name),
            ["Mega Drive (Emulador)", "Nintendo Switch (Mega Drive)"]
        )
    }

    func testCandidates_NintendoSwitch_OpensPicker() {
        let result = PlatformCoverResolver.candidates(matching: "Nintendo Switch", in: platforms)

        XCTAssertEqual(
            result.map(\.name),
            [
                "Nintendo Switch",
                "Nintendo Switch (GameBoy Advance)",
                "Nintendo Switch (Mega Drive)"
            ]
        )
    }

    func testCandidates_WiiUVirtualConsole_CollapsesToWiiU() {
        let result = PlatformCoverResolver.candidates(matching: "Wii U Virtual Console", in: platforms)

        XCTAssertEqual(result.map(\.name), ["Wii U (Virtual Console)"])
    }

    func testMatchTheGamesDB_NES() {
        let id = PlatformCoverResolver.matchTheGamesDBPlatform(
            coverSearchName: "NES",
            platforms: [
                (id: 7, name: "Nintendo Entertainment System (NES)", alias: "nes"),
                (id: 6, name: "Sega Mega Drive", alias: "genesis")
            ]
        )

        XCTAssertEqual(id, 7)
    }

    func testCatalogSearch_MegaManWiiU_UsesWiiUPlatform() {
        let tgdb: [(id: Int, name: String, alias: String?)] = [
            (id: 38, name: "Nintendo Wii U", alias: "wiiu"),
            (id: 9, name: "Nintendo Wii", alias: "wii")
        ]

        let parsed = PlatformCoverResolver.catalogSearch(from: "Mega Man WiiU", platforms: tgdb)

        XCTAssertEqual(parsed.gameName, "Mega Man")
        XCTAssertEqual(parsed.platformHint, "WiiU")
        XCTAssertEqual(
            PlatformCoverResolver.matchTheGamesDBPlatform(
                coverSearchName: parsed.platformHint ?? "",
                platforms: tgdb
            ),
            38
        )
    }

    func testCatalogSearch_MegaManWiiUSpaced_UsesWiiU() {
        let parsed = PlatformCoverResolver.catalogSearch(from: "Mega Man Wii U")

        XCTAssertEqual(parsed.gameName, "Mega Man")
        XCTAssertEqual(parsed.platformHint, "Wii U")
    }

    func testCatalogSearch_WiiSports_DoesNotTreatNameAsPlatform() {
        let parsed = PlatformCoverResolver.catalogSearch(from: "Wii Sports")

        XCTAssertEqual(parsed.gameName, "Wii Sports")
        XCTAssertNil(parsed.platformHint)
    }
}
