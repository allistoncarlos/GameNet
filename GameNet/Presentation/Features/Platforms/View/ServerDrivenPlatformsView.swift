//
//  ServerDrivenPlatformsView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 15/12/24.
//

import SwiftUI

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
                Text(platformId)
            }
            .navigationView(title: "Platformas")
            .toolbar {
                Button(action: {}) {
                    SwiftUI.NavigationLink(value: String()) {
                        Image(systemName: "plus")
                    }
                }
            }
            .overlay(
                GameNetProgressHUD($isLoading, config: GameNetApp.hudConfig)
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
