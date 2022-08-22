//
//  DashboardUIState.swift
//  GameNet
//
//  Created by Alliston Aleixo on 22/08/22.
//

import Foundation

enum DashboardUIState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}
