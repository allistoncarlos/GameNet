//
//  NotLoggedView.swift
//  GameNet.Watch Watch App
//
//  Created by Alliston Aleixo on 10/01/23.
//

import SwiftUI

struct NotLoggedView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Login necessário")
                .font(.headline)
            Text("Abra o GameNet no iPhone e faça login.")
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NotLoggedView()
}
