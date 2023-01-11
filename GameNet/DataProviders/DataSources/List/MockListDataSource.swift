//
//  MockListDataSource.swift
//  GameNet
//
//  Created by Alliston Aleixo on 11/01/23.
//

import Foundation
import GameNet_Network

class MockListDataSource: ListDataSourceProtocol {
    // MARK: Internal

    static func reset() {
        lists = Defaults.lists
    }

    func fetchData() async -> [List]? {
        return MockListDataSource.lists
    }

    func fetchData(id: String) async -> List? {
        MockListDataSource.lists.first { list in
            list.id == id
        }
    }

    func saveList(id: String?, list: List) async -> List? {
        if let id = id,
           let index = MockListDataSource.lists.firstIndex(where: { $0.id == id }) {
            MockListDataSource.lists[index] = list
        } else {
            let newList = List(id: "\(UUID())", name: list.name)
            MockListDataSource.lists.append(newList)
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
