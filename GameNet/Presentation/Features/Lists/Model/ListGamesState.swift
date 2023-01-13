//
//  ListGamesState.swift
//  GameNet
//
//  Created by Alliston Aleixo on 11/01/23.
//

import Foundation
import GameNet_Network

enum ListGamesState: Equatable {
    case idle
    case loading
    case success(GameNet_Network.List)
    case error(String)
}
