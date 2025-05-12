//
//  PlatformDataSource.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/08/22.
//

import Foundation
import GameNet_Network

// MARK: - PlatformDataSourceProtocol

protocol PlatformDataSourceProtocol {
    func fetchData(cache: Bool) async -> [Platform]?
    func fetchData(id: String) async -> Platform?
    func savePlatform(id: String?, platform: Platform) async -> Platform?
}

// MARK: - PlatformDataSource

class PlatformDataSource: PlatformDataSourceProtocol {
    func fetchData(cache: Bool = true) async -> [Platform]? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<PagedResult<PlatformResponse>>.self,
                endpoint: .platforms,
                cache: cache
            ) {
            if apiResult.ok {
                return apiResult.data.result
                    .compactMap { $0.toPlatform() }
                    .sorted(by: { $1.name.uppercased() > $0.name.uppercased() })
            }
        }

        return nil
    }

    func fetchData(id: String) async -> Platform? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<PlatformResponse>.self,
                endpoint: .platform(id: id)
            ) {
            if apiResult.ok {
                return apiResult.data.toPlatform()
            }
        }

        return nil
    }

    func savePlatform(id: String?, platform: Platform) async -> Platform? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<PlatformResponse>.self,
                endpoint: .savePlatform(id: id, data: platform.toRequest())
            ) {
            if apiResult.ok {
                return apiResult.data.toPlatform()
            }
        }

        return nil
    }
}
