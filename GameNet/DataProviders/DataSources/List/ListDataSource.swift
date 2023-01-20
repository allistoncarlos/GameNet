//
//  ListDataSource.swift
//  GameNet
//
//  Created by Alliston Aleixo on 10/01/23.
//

import Foundation
import GameNet_Network

// MARK: - ListDataSourceProtocol

protocol ListDataSourceProtocol {
    func fetchData() async -> [List]?
    func fetchData(id: String) async -> ListGame?
    func fetchFinishedByYearData(id: Int) async -> [ListItem]?
    func fetchBoughtByYearData(id: Int) async -> [ListItem]?
    func saveList(id: String?, list: List) async -> List?
}

// MARK: - ListDataSource

class ListDataSource: ListDataSourceProtocol {
    func fetchData() async -> [List]? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<PagedResult<ListResponse>>.self,
                endpoint: .lists
            ) {
            if apiResult.ok {
                return apiResult.data.result
                    .compactMap { $0.toList() }
                    .sorted(by: { $1.name.uppercased() > $0.name.uppercased() })
            }
        }

        return nil
    }

    func fetchData(id: String) async -> ListGame? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<ListGameResponse>.self,
                endpoint: .list(id: id)
            ) {
            if apiResult.ok {
                return apiResult.data.toListGame()
            }
        }

        return nil
    }

    func fetchFinishedByYearData(id: Int) async -> [ListItem]? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<[ListItemResponse]>.self,
                endpoint: .finishedByYearList(id: String(id))
            ) {
            if apiResult.ok {
                return apiResult.data.compactMap { $0.toListItem() }
            }
        }

        return nil
    }

    func fetchBoughtByYearData(id: Int) async -> [ListItem]? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<[ListItemResponse]>.self,
                endpoint: .boughtByYearList(id: String(id))
            ) {
            if apiResult.ok {
                return apiResult.data.compactMap { $0.toListItem() }
            }
        }

        return nil
    }

    func saveList(id: String?, list: List) async -> List? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<ListResponse>.self,
                endpoint: .saveList(id: id, data: list.toRequest())
            ) {
            if apiResult.ok {
                return apiResult.data.toList()
            }
        }

        return nil
    }
}
