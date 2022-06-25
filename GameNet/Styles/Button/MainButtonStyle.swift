//
//  MainButtonStyle.swift
//  GameNet
//
//  Created by Alliston Aleixo on 25/06/22.
//

import SwiftUI

struct MainButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(
                minWidth: 0,
                maxWidth: .infinity
            )
            .background(Color.main)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .font(.system(size: 18, weight: .bold))
    }
}
