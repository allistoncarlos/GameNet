//
//  DashboardDataSource.swift
//  GameNet
//
//  Created by Alliston Aleixo on 22/08/22.
//

import Foundation

// MARK: - DashboardDataSourceProtocol

protocol DashboardDataSourceProtocol {
    func fetchData() async -> Dashboard?
}

// MARK: - DashboardDataSource

class DashboardDataSource: DashboardDataSourceProtocol {
    func fetchData() async -> Dashboard? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<DashboardResponseDTO>.self,
                endpoint: .dashboard
            ) {
            if apiResult.ok {
                return apiResult.data.toDashboard()
            }
        }

        return nil
    }
}
