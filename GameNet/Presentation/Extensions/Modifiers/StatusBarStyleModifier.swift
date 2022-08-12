//
//  StatusBarStyleModifier.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import SwiftUI

struct StatusBarStyleModifier: ViewModifier {
    let color: Color
    let material: Material
    let hidden: Bool

    func body(content: Content) -> some View {
        ZStack {
            VStack {
                GeometryReader { geo in
                    color
                        .background(material) // SwiftUI 3+ only
                        .frame(height: geo.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
            }

            content
        }
        .statusBar(hidden: hidden)
    }
}
