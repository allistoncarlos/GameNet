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
