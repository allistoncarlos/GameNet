//
//  DashboardRepository.swift
//  GameNet
//
//  Created by Alliston Aleixo on 22/08/22.
//

import Factory
import Foundation
import GameNet_Network

// MARK: - DashboardRepositoryProtocol

protocol DashboardRepositoryProtocol {
    func fetchData() async -> Dashboard?
}

// MARK: - DashboardRepository

struct DashboardRepository: DashboardRepositoryProtocol {
    // MARK: Internal

    func fetchData() async -> Dashboard? {
        return await dataSource.fetchData()
    }

    // MARK: Private

    @Injected(DataSourceContainer.dashboardDataSource) private var dataSource
}
