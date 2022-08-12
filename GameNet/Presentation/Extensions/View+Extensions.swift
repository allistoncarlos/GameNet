//
//  View+Extensions.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import SwiftUI

extension View {
    func statusBarStyle(
        color: Color = .clear,
        material: Material = .bar,
        hidden: Bool = false
    ) -> some View {
        modifier(StatusBarStyleModifier(
            color: color,
            material: material,
            hidden: hidden
        ))
    }
}
