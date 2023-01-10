//
//  DashboardState.swift
//  GameNet
//
//  Created by Alliston Aleixo on 22/08/22.
//

import Foundation
import GameNet_Network

enum DashboardState: Equatable {
    case idle
    case loading
    case success(Dashboard)
    case error(String)
}
