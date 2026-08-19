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
        #elseif os(iOS)
        content
            .navigationTitle(title ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .gameNetInlineToolbarTitle()
            .toolbarBackground(color, for: .navigationBar, .tabBar)
            .toolbarBackground(.visible, for: .navigationBar, .tabBar)
            .toolbarColorScheme(.dark, for: .navigationBar, .tabBar)
        #else
        content
            .navigationTitle(title ?? "")
        #endif
    }
}
