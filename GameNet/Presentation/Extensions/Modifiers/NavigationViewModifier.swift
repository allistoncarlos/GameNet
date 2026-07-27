//
//  NavigationViewModifier.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/08/22.
//

import SwiftUI

struct NavigationViewModifier: ViewModifier {
    let title: String?
    let color: Color

    func body(content: Content) -> some View {
        #if os(macOS)
        content
            .navigationTitle(title ?? "")
            .toolbarBackground(color, for: .windowToolbar)
            .toolbarBackground(.visible, for: .windowToolbar)
        #else
        content
            .navigationTitle(title ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarTitleDisplayMode(.inline)
            .toolbarBackground(color, for: .navigationBar, .tabBar)
            .toolbarBackground(.visible, for: .navigationBar, .tabBar)
            .toolbarColorScheme(.dark, for: .navigationBar, .tabBar)
        #endif
    }
}
