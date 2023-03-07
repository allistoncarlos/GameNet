//
//  GameNetApp+RepositoryInjection.swift
//  GameNet
//
//  Created by Alliston Aleixo on 02/08/22.
//

import Factory
import Foundation
import GameNet_Network

class RepositoryContainer: SharedContainer {
    static let loginRepository = Factory<LoginRepositoryProtocol> { LoginRepository() }
    static let dashboardRepository = Factory<DashboardRepositoryProtocol> { DashboardRepository() }
    static let platformRepository = Factory<PlatformRepositoryProtocol> { PlatformRepository() }
    static let gameRepository = Factory<GameRepositoryProtocol> { GameRepository() }
    static let listRepository = Factory<ListRepositoryProtocol> { ListRepository() }
    static let gameplaySessionRepository = Factory<GameplaySessionRepositoryProtocol> { GameplaySessionRepository() }
}
