//
//  ServerDrivenDashboardState.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/11/24.
//

import Foundation
import GameNet_Network

enum ServerDrivenDashboardState: Equatable {
    case idle
    case loading
    case success(ServerDriven)
    case error(String)
}
