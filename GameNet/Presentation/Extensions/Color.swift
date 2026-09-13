//
//  Color.swift
//  GameNet
//
//  Created by Alliston Aleixo on 25/06/22.
//

import SwiftUI

extension Color {
    private enum CustomColor: String {
        case main = "Main"
        case disabled = "Disabled"
        case primaryCardBackground = "PrimaryCardBackground"
        case secondaryCardBackground = "SecondaryCardBackground"
        case tertiaryCardBackground = "TertiaryCardBackground"
    }

    static let main = Color(CustomColor.main.rawValue)
    static let disabled = Color(CustomColor.disabled.rawValue)
    static let primaryCardBackground = Color(CustomColor.primaryCardBackground.rawValue)
    static let secondaryCardBackground = Color(CustomColor.secondaryCardBackground.rawValue)
    static let tertiaryCardBackground = Color(CustomColor.tertiaryCardBackground.rawValue)

}
