//
//  ServerDrivenPlatformsView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 15/12/24.
//

import SwiftUI
import TTProgressHUD

struct ServerDrivenPlatformsView: View {
    @ObservedObject var viewModel: ServerDrivenPlatformsViewModel
    @State var isLoading = true

    var body: some View {
        NavigationStack(path: $presentedPlatforms) {
            VStack {
                if let dynamicContainer = viewModel.dynamicContainer {
                    renderChildren(components: Array(CollectionOfOne(dynamicContainer)))
                }
            }
            .disabled(isLoading)
            .padding(.top, 10)
            .navigationDestination(for: String.self) { platformId in
                #if os(iOS)
                    Text(platformId)
                #endif
            }
            .navigationView(title: "Platformas")
            .toolbar {
                #if os(iOS)
                Button(action: {}) {
                    SwiftUI.NavigationLink(value: String()) {
                        Image(systemName: "plus")
                    }
                }
                #endif
            }
            .overlay(
                TTProgressHUD($isLoading, config: GameNetApp.hudConfig)
            )
            .onChange(of: presentedPlatforms) { _, newValue in
                if newValue.isEmpty {
                    Task {
                        await viewModel.fetchData()
                    }
                }
            }
            .onChange(of: viewModel.state) { _, state in
                isLoading = state == .loading
            }
            .task {
                await viewModel.fetchData()
            }
        }
    }
    
    @State private var presentedPlatforms = NavigationPath()
}

#Preview {
    ServerDrivenPlatformsView(viewModel: ServerDrivenPlatformsViewModel())
}
