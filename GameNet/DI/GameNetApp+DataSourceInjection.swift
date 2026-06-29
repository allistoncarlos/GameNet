//
//  GameNetApp+DataSourceInjection.swift
//  GameNet
//
//  Created by Alliston Aleixo on 02/08/22.
//

import Factory
import Foundation

extension Container {
    var loginDataSource: Factory<LoginDataSourceProtocol> { self { LoginDataSource() } }
    var dashboardDataSource: Factory<DashboardDataSourceProtocol> { self { DashboardDataSource() } }
    var platformDataSource: Factory<PlatformDataSourceProtocol> { self { PlatformDataSource() } }
    var gameDataSource: Factory<GameDataSourceProtocol> { self { GameDataSource() } }
    var listDataSource: Factory<ListDataSourceProtocol> { self { ListDataSource() } }
    var gameplaySessionDataSource: Factory<GameplaySessionDataSourceProtocol> { self { GameplaySessionDataSource() } }
    var serverDrivenDataSource: Factory<ServerDrivenDataSourceProtocol> { self { ServerDrivenDataSource() } }
    var funDataSource: Factory<FunDataSourceProtocol> { self { FunDataSource() } }
    var tokenDataSource: Factory<TokenDataSourceProtocol> { self { TokenDataSource() } }
}
