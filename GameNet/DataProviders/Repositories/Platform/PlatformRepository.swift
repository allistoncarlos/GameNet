//
//  PlatformRepository.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/08/22.
//

import Factory
import Foundation
import GameNet_Network

// MARK: - PlatformRepositoryProtocol

protocol PlatformRepositoryProtocol {
    func fetchData() async -> [Platform]?
    func fetchData(id: String) async -> Platform?
    @discardableResult func savePlatform(id: String?, platform: Platform) async -> Platform?
}

// MARK: - PlatformRepository

struct PlatformRepository: PlatformRepositoryProtocol {
    // MARK: Internal

    func fetchData() async -> [Platform]? {
        return await dataSource.fetchData()
    }

    func fetchData(id: String) async -> Platform? {
        return await dataSource.fetchData(id: id)
    }

    func savePlatform(id: String?, platform: Platform) async -> Platform? {
        return await dataSource.savePlatform(id: id, platform: platform)
    }

    // MARK: Private

    @Injected(DataSourceContainer.platformDataSource) private var dataSource
}
