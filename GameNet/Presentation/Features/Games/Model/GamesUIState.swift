//
//  GamesUIState.swift
//  GameNet
//
//  Created by Alliston Aleixo on 20/10/22.
//

import Foundation

enum GamesUIState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}
