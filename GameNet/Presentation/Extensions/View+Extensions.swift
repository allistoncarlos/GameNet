//
//  View+Extensions.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import SwiftUI

extension View {
    func navigationView(title: String?, color: Color = .main) -> some View {
        modifier(NavigationViewModifier(title: title, color: color))
    }
}
