//
//  MockListRepository.swift
//  GameNet
//
//  Created by Alliston Aleixo on 11/01/23.
//

import Foundation
import GameNet_Network

struct MockListRepository: ListRepositoryProtocol {

    // MARK: Internal

    static func reset() {
        lists = Defaults.lists
        listGames = Defaults.listGames
    }

    func fetchData() -> [List]? {
        return MockListRepository.lists
    }

    func fetchData(id: String) -> ListGame? {
        MockListRepository.listGames.first { list in
            list.id == id
        }
    }

    func fetchFinishedByYearData(id: Int) async -> [ListItem]? {
        return MockListRepository.listGames.first?.games?.filter { $0.year == id }
    }

    func fetchBoughtByYearData(id: Int) async -> [ListItem]? {
        return MockListRepository.listGames.first?.games?.filter { $0.year == id }
    }

    func saveList(id: String?, userId: String?, list: ListGame) async -> List? {
        if let id = id,
           let index = MockListRepository.lists.firstIndex(where: { $0.id == id }) {
            MockListRepository.listGames[index] = list
        } else {
            let newList = List(id: "\(UUID())", name: list.name)
            MockListRepository.lists.append(newList)
        }

        return List(id: list.id, name: list.name)
    }

    // MARK: Private

    private enum Defaults {
        static let lists = [
            List(id: "1", name: "Próximos Jogos"),
            List(id: "2", name: "Melhores Zeldas"),
        ]

        static let listGames = [
            ListGame(
                id: "1",
                name: "Lista Padrão",
                games: [
                    ListItem(
                        id: "1",
                        name: "The Legend of Zelda: Tears of the Kingdom",
                        platform: "Nintendo Switch",
                        userGameId: "123",
                        year: 2023,
                        boughtDate: nil,
                        value: 0,
                        start: nil,
                        finish: nil,
                        cover: "https://images.nintendolife.com/da314926e706f/switch-tloz-totk-boxart-011.large.jpg",
                        order: 1,
                        comment: "No comment"
                    ),
                    ListItem(
                        id: "2",
                        name: "The Legend of Zelda: Breath of the Wild",
                        platform: "Nintendo Switch",
                        userGameId: "456",
                        year: 2023,
                        boughtDate: nil,
                        value: 0,
                        start: nil,
                        finish: nil,
                        cover: "https://assets.reedpopcdn.com/148430785862.jpg/BROK/resize/1920x1920%3E/format/jpg/quality/80/148430785862.jpg",
                        order: 2,
                        comment: "No comment"
                    )
                ]
            )
        ]
    }

    private static var lists = Defaults.lists
    private static var listGames = Defaults.listGames
}
