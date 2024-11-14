//
//  PlatformsView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import SwiftUI
import TTProgressHUD

// MARK: - PlatformsView

struct PlatformsView: View {

    // MARK: Internal

    @ObservedObject var viewModel: PlatformsViewModel
    @State var isLoading = true

    var body: some View {
        NavigationStack(path: $presentedPlatforms) {
            VStack {
                if let platforms = viewModel.platforms {
                    List(platforms, id: \.id) { platform in
                        #if os(iOS)
                        NavigationLink(platform.name, value: platform.id)
                        #else
                        Text(platform.name)
                        #endif
                    }
                }
            }
            .disabled(isLoading)
            .padding(.top, 10)
            .navigationDestination(for: String.self) { platformId in
                #if os(iOS)
                viewModel.editPlatformView(
                    navigationPath: $presentedPlatforms,
                    platformId: platformId
                )
                #endif
            }
            .navigationView(title: "Platformas")
            .toolbar {
                #if os(iOS)
                Button(action: {}) {
                    NavigationLink(value: String()) {
                        Image(systemName: "plus")
                    }
                }
                #endif
            }
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

    // MARK: Private

    @State private var presentedPlatforms = NavigationPath()
}

// MARK: - Previews

#Preview("Dark Mode") {
    let _ = RepositoryContainer.platformRepository.register(factory: { MockPlatformRepository() })

    PlatformsView(viewModel: PlatformsViewModel()).preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    let _ = RepositoryContainer.platformRepository.register(factory: { MockPlatformRepository() })

    PlatformsView(viewModel: PlatformsViewModel()).preferredColorScheme(.light)
}
