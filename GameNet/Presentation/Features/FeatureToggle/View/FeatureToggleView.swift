//
//  FeatureToggleView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 13/11/24.
//

import SwiftUI

struct FeatureToggleView: View {
    @ObservedObject var viewModel: FeatureToggleViewModel
    @State var isLoading = true
    
    var body: some View {
        List(viewModel.featureToggles, id: \.id) { feature in
            Toggle(isOn: .constant(false), label: {
                Text(feature.rawValue)
            })
        }
        .navigationView(title: "Feature Toggle")
        .safeAreaInset(edge: VerticalEdge.bottom) {
            Button("Salvar") {
                print("tapped!")
            }
            .padding(.horizontal)
            .buttonStyle(MainButtonStyle())
        }
        .padding(.vertical)
    }
}

#Preview {
    FeatureToggleView(viewModel: FeatureToggleViewModel())
}
