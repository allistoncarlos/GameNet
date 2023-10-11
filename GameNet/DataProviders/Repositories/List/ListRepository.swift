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
    func fetchData(id: String) async -> ListGame?
    func fetchFinishedByYearData(id: Int) async -> [ListItem]?
    func fetchBoughtByYearData(id: Int) async -> [ListItem]?
    func saveList(id: String?, userId: String?, list: ListGame) async -> List?
}

// MARK: - ListRepository

struct ListRepository: ListRepositoryProtocol {

    // MARK: Internal

    func fetchData() async -> [List]? {
        return await dataSource.fetchData()
    }

    func fetchData(id: String) async -> ListGame? {
        return await dataSource.fetchData(id: id)
    }
    
    func fetchFinishedByYearData(id: Int) async -> [ListItem]? {
        return await dataSource.fetchFinishedByYearData(id: id)
    }
    
    func fetchBoughtByYearData(id: Int) async -> [ListItem]? {
        return await dataSource.fetchBoughtByYearData(id: id)
    }

    func saveList(id: String?, userId: String?, list: ListGame) async -> List? {
        return await dataSource.saveList(id: id, userId: userId, list: list)
    }

    // MARK: Private

    @Injected(DataSourceContainer.listDataSource) private var dataSource
}
