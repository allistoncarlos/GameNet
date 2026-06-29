//
//  PlatformsState.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/08/22.
//

import Foundation

enum PlatformsState: Equatable {
    case idle
    case loading
    case success([Platform])
    case error(String)
}
