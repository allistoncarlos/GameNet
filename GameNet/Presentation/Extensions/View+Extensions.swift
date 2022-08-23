//
//  View+Extensions.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import SwiftUI

extension View {
    func statusBarStyle(title: String?, color: Color = .clear) -> some View {
        modifier(NavigationViewModifier(title: title, color: color))
    }
}
