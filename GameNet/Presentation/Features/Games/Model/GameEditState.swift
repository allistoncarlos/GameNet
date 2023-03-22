//
//  GameEditState.swift
//  GameNet
//
//  Created by Alliston Aleixo on 22/03/23.
//

import Foundation
import GameNet_Network

enum GameEditState: Equatable {
    case idle
    case loading
    case loadedPlatforms([Platform]?)
    case saved
    case error(String)
}
