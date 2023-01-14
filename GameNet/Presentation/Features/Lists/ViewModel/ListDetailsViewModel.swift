//
//  ListDetailsViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 14/01/23.
//

import Combine
import Factory
import Foundation
import GameNet_Network
import SwiftUI

// MARK: - ListDetailsViewModel

@MainActor
class ListDetailsViewModel: ObservableObject {

    // MARK: Lifecycle

    init(originFlow: ListOriginFlow) {
        self.originFlow = originFlow

        switch originFlow {
        case let .finishedByYear(year):
            name = "Finalizados em \(year)"
        case let .boughtByYear(year):
            name = "Comprados em \(year)"
        }
    }

    // MARK: Internal

    var originFlow: ListOriginFlow
    var name: String
}
