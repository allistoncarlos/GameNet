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
    @State var overrideRemoteConfigs: Bool
    
    var body: some View {
        Form {
            Section("Principal") {
                Toggle("Sobrepor configurações remotas", isOn: $overrideRemoteConfigs)
            }
            
            Section("Configurações") {
                ForEach($viewModel.featureToggles, id: \.id) { ($feature: Binding<RemoteConfigModel>) in
                    Toggle(feature.featureToggle, isOn: $feature.enabled)
                }
                .disabled(!overrideRemoteConfigs)
            }
        }
        .navigationView(title: "Feature Toggle")
        .safeAreaInset(edge: VerticalEdge.bottom) {
            Button("Salvar") {
                viewModel.save(overrideRemoteConfigs: overrideRemoteConfigs)
            }
            .padding(.horizontal)
            .buttonStyle(MainButtonStyle())
        }
    }
}

#Preview {
    FeatureToggleView(viewModel: FeatureToggleViewModel(), overrideRemoteConfigs: false)
}
