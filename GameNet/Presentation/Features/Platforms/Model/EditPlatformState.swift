//
//  EditPlatformState.swift
//  GameNet
//
//  Created by Alliston Aleixo on 24/08/22.
//

import Foundation

enum EditPlatformState: Equatable {
    case idle
    case loading
    case success(Platform)
    case error(String)
}
