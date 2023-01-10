//
//  NavigationViewModifier.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/08/22.
//

import SwiftUI

// MARK: - NewNavigationViewModifier

// TODO: iOS 16 - https://sarunw.com/posts/swiftui-navigation-bar-color/
struct NavigationViewModifier: ViewModifier {
    let title: String?
    let color: Color

    func body(content: Content) -> some View {
        ZStack {
            VStack {
                color
                    .frame(height: 148)
                    .ignoresSafeArea(.container, edges: .top)

                Spacer()
            }

            VStack {
                Rectangle()
                    .frame(height: 0)
                    .background(color)

                content
            }
            .navigationTitle(title ?? "")
        }
    }
}
