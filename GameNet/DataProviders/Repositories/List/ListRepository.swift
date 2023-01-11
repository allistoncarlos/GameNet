//
//  ListRepository.swift
//  GameNet
//
//  Created by Alliston Aleixo on 10/01/23.
//

import Factory
import Foundation
import GameNet_Network

// MARK: - ListRepositoryProtocol

protocol ListRepositoryProtocol {
    func fetchData() async -> [List]?
    func fetchData(id: String) async -> List?
    func saveList(id: String?, list: List) async -> List?
}

// MARK: - ListRepository

struct ListRepository: ListRepositoryProtocol {

    // MARK: Internal

    func fetchData() async -> [List]? {
        return await dataSource.fetchData()
    }

    func fetchData(id: String) async -> List? {
        return await dataSource.fetchData(id: id)
    }

    func saveList(id: String?, list: List) async -> List? {
        return await dataSource.saveList(id: id, list: list)
    }

    // MARK: Private

    @Injected(DataSourceContainer.listDataSource) private var dataSource
}
