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
    func fetchData() async -> [Platform]?
    func fetchData(id: String) async -> Platform?
    func savePlatform(id: String?, platform: Platform) async -> Platform?
}

// MARK: - PlatformDataSource

class PlatformDataSource: PlatformDataSourceProtocol {
    func fetchData() async -> [Platform]? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<[PlatformResponse]>.self,
                endpoint: .platforms
            ) {
            if apiResult.ok {
                return apiResult.data.map { $0.toPlatform() }
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
