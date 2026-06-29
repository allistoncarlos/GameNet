//
//  GameNetApp+RepositoryInjection.swift
//  GameNet
//
//  Created by Alliston Aleixo on 02/08/22.
//

import Factory
import Foundation

extension Container {
    var loginRepository: Factory<LoginRepositoryProtocol> { self { LoginRepository() } }
    var dashboardRepository: Factory<DashboardRepositoryProtocol> { self { DashboardRepository() } }
    var platformRepository: Factory<PlatformRepositoryProtocol> { self { PlatformRepository() } }
    var gameRepository: Factory<GameRepositoryProtocol> { self { GameRepository() } }
    var listRepository: Factory<ListRepositoryProtocol> { self { ListRepository() } }
    var gameplaySessionRepository: Factory<GameplaySessionRepositoryProtocol> { self { GameplaySessionRepository() } }
    var serverDrivenRepository: Factory<ServerDrivenRepositoryProtocol> { self { ServerDrivenRepository() } }
    var funRepository: Factory<FunRepositoryProtocol> { self { FunRepository() } }
}
