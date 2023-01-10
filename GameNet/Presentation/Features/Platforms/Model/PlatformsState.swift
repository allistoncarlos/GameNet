//
//  PlatformsState.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/08/22.
//

import Foundation
import GameNet_Network

enum PlatformsState: Equatable {
    case idle
    case loading
    case success([Platform])
    case error(String)
}
