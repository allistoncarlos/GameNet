//
//  RemoteConfigModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 13/11/24.
//

import Foundation

struct RemoteConfigModel: Identifiable, Codable {
    var id = UUID()
    var featureToggle: String
    var enabled: Bool
}
