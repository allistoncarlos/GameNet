//
//  NavigationViewModifier.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/08/22.
//

import SwiftUI

// MARK: - NewNavigationViewModifier

struct NavigationViewModifier: ViewModifier {
    let title: String?
    let color: Color

    func body(content: Content) -> some View {
        content
            .navigationTitle(title ?? "")
            .toolbarBackground(color, for: .navigationBar, .tabBar)
            .toolbarBackground(.visible, for: .navigationBar, .tabBar)
            .toolbarColorScheme(.dark, for: .navigationBar, .tabBar)
    }
}
