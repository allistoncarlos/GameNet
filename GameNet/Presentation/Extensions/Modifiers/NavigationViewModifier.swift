//
//  NavigationViewModifier.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/08/22.
//

import SwiftUI

// TODO: iOS 16 - https://sarunw.com/posts/swiftui-navigation-bar-color/
struct NavigationViewModifier: ViewModifier {
    let title: String?
    let color: Color

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        if let title = title {
                            Text(title)
                                .font(.largeTitle.weight(.bold))
                        }
                        Spacer()
                    }
                }
                .padding(.top, 28)
                .padding()
                .background(color)
            }
            .navigationBarHidden(true)
    }
}
