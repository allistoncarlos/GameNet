//
//  GameDetailState.swift
//  GameNet
//
//  Created by Alliston Aleixo on 24/01/23.
//

import Foundation
import GameNet_Network

enum GameDetailState: Equatable {
    case idle
    case loading
    case successGame(GameDetail)
    case successGameplays(GameplaySessions)
    case successSave(GameplaySession)
    case error(String)
}
