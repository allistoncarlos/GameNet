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
    static let platformDataSource = Factory<PlatformDataSourceProtocol> { PlatformDataSource() }
    static let gameDataSource = Factory<GameDataSourceProtocol> { GameDataSource() }
    static let listDataSource = Factory<ListDataSourceProtocol> { ListDataSource() }
    static let gameplaySessionDataSource = Factory<GameplaySessionDataSourceProtocol> { GameplaySessionDataSource() }
    
    static let serverDrivenDataSource = Factory<ServerDrivenDataSourceProtocol> { ServerDrivenDataSource() }
}
