//
//  PlatformsUIState.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/08/22.
//

import Foundation

enum PlatformsUIState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}
