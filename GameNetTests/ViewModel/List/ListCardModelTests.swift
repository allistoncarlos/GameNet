//
//  ListCardModelTests.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 14/08/26.
//

@testable import GameNet
import XCTest

final class ListCardModelTests: XCTestCase {
    func testPreviewGames_WhenMoreThanThree_ShouldReturnFirstThree() {
        let model = ListCardModel(list: sampleList, games: sampleGames(count: 5))

        XCTAssertEqual(model.previewGames.count, 3)
        XCTAssertEqual(model.previewGames.map(\.id), ["1", "2", "3"])
    }

    func testPreviewGames_WhenThreeOrFewer_ShouldReturnAllGames() {
        XCTAssertEqual(ListCardModel(list: sampleList, games: sampleGames(count: 3)).previewGames.count, 3)
        XCTAssertEqual(ListCardModel(list: sampleList, games: sampleGames(count: 2)).previewGames.count, 2)
        XCTAssertEqual(ListCardModel(list: sampleList, games: sampleGames(count: 1)).previewGames.count, 1)
        XCTAssertTrue(ListCardModel(list: sampleList, games: []).previewGames.isEmpty)
    }

    func testOverflowCount_WhenMoreThanThree_ShouldBeTotalMinusTwo() {
        XCTAssertEqual(ListCardModel(list: sampleList, games: sampleGames(count: 15)).overflowCount, 13)
        XCTAssertEqual(ListCardModel(list: sampleList, games: sampleGames(count: 4)).overflowCount, 2)
        XCTAssertEqual(ListCardModel(list: sampleList, games: sampleGames(count: 5)).overflowCount, 3)
    }

    func testOverflowCount_WhenThreeOrFewer_ShouldBeNil() {
        XCTAssertNil(ListCardModel(list: sampleList, games: sampleGames(count: 3)).overflowCount)
        XCTAssertNil(ListCardModel(list: sampleList, games: sampleGames(count: 2)).overflowCount)
        XCTAssertNil(ListCardModel(list: sampleList, games: sampleGames(count: 1)).overflowCount)
        XCTAssertNil(ListCardModel(list: sampleList, games: []).overflowCount)
    }

    private var sampleList: GameNet.List {
        GameNet.List(id: "1", name: "Favoritos")
    }

    private func sampleGames(count: Int) -> [ListItem] {
        (1...count).map { index in
            ListItem(
                id: "\(index)",
                name: "Game \(index)",
                platform: "Switch",
                userGameId: "user-\(index)",
                year: 2023,
                boughtDate: nil,
                value: 0,
                start: nil,
                finish: nil,
                cover: "https://example.com/\(index).jpg",
                order: index,
                comment: nil
            )
        }
    }
}
