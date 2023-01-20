//
//  ListsState.swift
//  GameNet
//
//  Created by Alliston Aleixo on 10/01/23.
//

import Foundation
import GameNet_Network

enum ListsState: Equatable {
    case idle
    case loading
    case success([List])
    case error(String)
}
