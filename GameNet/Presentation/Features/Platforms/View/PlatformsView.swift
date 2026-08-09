//
//  PlatformsView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import Factory
import SwiftUI

struct PlatformsView: View {

    @ObservedObject var viewModel: PlatformsViewModel
    @State var isLoading = true

    var body: some View {
        NavigationStack(path: $presentedPlatforms) {
            VStack {
                if let platforms = viewModel.platforms {
                    SwiftUI.List(platforms, id: \.id) { platform in
                        SwiftUI.NavigationLink(platform.name, value: platform.id)
                    }
                }
            }
            .disabled(isLoading)
            .padding(.top, 10)
            .navigationDestination(for: String.self) { platformId in
                viewModel.editPlatformView(
                    navigationPath: $presentedPlatforms,
                    platformId: platformId.isEmpty ? nil : platformId
                )
            }
            .navigationView(title: "Platformas")
            .toolbar {
                Button(action: {}) {
                    SwiftUI.NavigationLink(value: String()) {
                        Image(systemName: "plus")
                    }
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
        .refreshable {
            Task {
                await viewModel.fetchData(cache: false)
            }
        }
        .task {
            await viewModel.fetchData()
        }
    }

    @State private var presentedPlatforms = NavigationPath()
}
