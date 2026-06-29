//
//  GameCoverState.swift
//  GameNet
//
//  Created by Alliston Aleixo on 14/11/24.
//

import Foundation

enum GameCoverState: Equatable {
    case idle
    case loading
    case success(GameplaySession)
    case error(String)
}
