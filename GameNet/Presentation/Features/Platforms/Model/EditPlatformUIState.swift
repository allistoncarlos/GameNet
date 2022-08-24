//
//  EditPlatformUIState.swift
//  GameNet
//
//  Created by Alliston Aleixo on 24/08/22.
//

import Foundation

enum EditPlatformUIState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}
