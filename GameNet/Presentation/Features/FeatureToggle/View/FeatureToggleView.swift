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
    @State private var isRemoveAllDataSheetPresented = false
    
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
        .toolbar {
            Button(action: {
                self.isRemoveAllDataSheetPresented = true
            }, label: {
                Image(systemName: "clear")
            })
            .confirmationDialog("", isPresented: $isRemoveAllDataSheetPresented) {
                Button("Confirmar") {
                    viewModel.removeAllData()
                }
                Button("Cancelar", role: .cancel) { }
            } message: {
                Text("Deseja limpar as configurações?")
            }
        }
        
        .safeAreaInset(edge: VerticalEdge.bottom) {
            Button("Salvar") {
                viewModel.save(overrideRemoteConfigs: overrideRemoteConfigs)
            }
            .padding(.horizontal)
            .buttonStyle(MainButtonStyle())
        }
        .padding(.bottom)
    }
}

#Preview {
    FeatureToggleView(viewModel: FeatureToggleViewModel(), overrideRemoteConfigs: false)
}
