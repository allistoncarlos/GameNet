//
//  ActionButtonStyle.swift
//  GameNet
//
//  Created by Alliston Aleixo on 13/11/24.
//

import SwiftUI

struct ActionButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(
                minWidth: 0,
                maxWidth: 200,
                minHeight: 0,
                maxHeight: 40
            )
            .background(isEnabled ? Color.secondaryCardBackground : Color.disabled)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .font(.system(size: 18, weight: .bold))
    }
}
