//
//  CoverImageCacheTests.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 14/08/26.
//

@testable import GameNet
import XCTest

final class CoverImageCacheTests: XCTestCase {
    private let testURL = "https://gamenet.example/cover-cache-test.png"

    override func tearDown() {
        if let request = CoverImageCache.request(for: testURL) {
            CoverImageCache.urlCache.removeCachedResponse(for: request)
        }

        super.tearDown()
    }

    func testRequest_WhenURLIsEmpty_ShouldReturnNil() {
        XCTAssertNil(CoverImageCache.request(for: ""))
        XCTAssertNil(CoverImageCache.request(for: "   "))
    }

    func testStore_ShouldReturnCachedData() {
        let pngData = Data(
            base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=="
        )!
        let url = URL(string: testURL)!
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "image/png"]
        )!

        CoverImageCache.store(data: pngData, response: response, for: testURL)

        XCTAssertEqual(CoverImageCache.cachedData(for: testURL), pngData)
    }
}
