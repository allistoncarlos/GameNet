//
//  SlugTests.swift
//  GameNetTests
//

@testable import GameNet
import XCTest

final class SlugTests: XCTestCase {
    func testGenerate_PlatformNames_MatchGameCoverSlugStyle() {
        XCTAssertEqual(Slug.generate("PlayStation 3 (PSOne Classics)"), "playstation-3-psone-classics")
        XCTAssertEqual(Slug.generate("Nintendo Switch (Emulador)"), "nintendo-switch-emulador")
        XCTAssertEqual(Slug.generate("R36S (GBA)"), "r36s-gba")
        XCTAssertEqual(Slug.generate("iOS"), "ios")
        XCTAssertEqual(Slug.generate("XBox 360 (Emulador)"), "xbox-360-emulador")
        XCTAssertEqual(
            PlatformIllustration.urlString(for: "Nintendo Switch"),
            "https://allistoncarlos.blob.core.windows.net/gamenet/platforms/nintendo-switch.png"
        )
    }
}
