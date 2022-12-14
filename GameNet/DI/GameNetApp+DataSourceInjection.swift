//
//  GameNetApp+DataSourceInjection.swift
//  GameNet
//
//  Created by Alliston Aleixo on 02/08/22.
//

import Factory
import Foundation

class DataSourceContainer: SharedContainer {
    static let loginDataSource = Factory<LoginDataSourceProtocol> { LoginDataSource() }
    static let dashboardDataSource = Factory<DashboardDataSourceProtocol> { DashboardDataSource() }
}
