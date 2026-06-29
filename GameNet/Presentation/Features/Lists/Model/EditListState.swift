//
//  EditListState.swift
//  GameNet
//
//  Created by Alliston Aleixo on 11/01/23.
//

import Foundation

enum EditListState: Equatable {
    case idle
    case loading
    case loadedGames(ListGame)
    case success(GameNet.List)
    case error(String)
}
