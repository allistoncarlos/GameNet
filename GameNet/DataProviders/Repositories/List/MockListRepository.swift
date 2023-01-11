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
    }

    func fetchData() async -> [List]? {
        return MockListRepository.lists
    }

    func fetchData(id: String) async -> List? {
        MockListRepository.lists.first { list in
            list.id == id
        }
    }

    func saveList(id: String?, list: List) async -> List? {
        if let id = id,
           let index = MockListRepository.lists.firstIndex(where: { $0.id == id }) {
            MockListRepository.lists[index] = list
        } else {
            let newList = List(id: "\(UUID())", name: list.name)
            MockListRepository.lists.append(newList)
        }

        return list
    }

    // MARK: Private

    private enum Defaults {
        static let lists = [
            List(id: "1", name: "Próximos Jogos"),
            List(id: "2", name: "Melhores Zeldas"),
        ]
    }

    private static var lists = Defaults.lists
}
