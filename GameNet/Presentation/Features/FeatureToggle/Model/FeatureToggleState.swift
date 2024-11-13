//
//  FeatureToggleState.swift
//  GameNet
//
//  Created by Alliston Aleixo on 13/11/24.
//

import Foundation

enum FeatureToggleState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}
