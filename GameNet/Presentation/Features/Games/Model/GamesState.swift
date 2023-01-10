//
//  GamesState.swift
//  GameNet
//
//  Created by Alliston Aleixo on 20/10/22.
//

import Foundation

enum GamesState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}
