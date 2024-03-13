//
//  PlatformsView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import SwiftUI
//import TTProgressHUD

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
                        NavigationLink(platform.name, value: platform.id)
                    }
                }
            }
            .disabled(isLoading)
            .padding(.top, 10)
            .navigationDestination(for: String.self) { platformId in
                viewModel.editPlatformView(
                    navigationPath: $presentedPlatforms,
                    platformId: platformId
                )
            }
            .navigationView(title: "Platformas")
            .toolbar {
                Button(action: {}) {
                    NavigationLink(value: String()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
//        .overlay(
//            TTProgressHUD($isLoading, config: GameNetApp.hudConfig)
//        )
        .onChange(of: presentedPlatforms) { newValue in
            if newValue.isEmpty {
                Task {
                    await viewModel.fetchData()
                }
            }
        }
        .onChange(of: viewModel.state) { state in
            isLoading = state == .loading
        }
        .task {
            await viewModel.fetchData()
        }
    }

    // MARK: Private

    @State private var presentedPlatforms = NavigationPath()
}

// MARK: - PlatformsView_Previews

struct PlatformsView_Previews: PreviewProvider {
    static var previews: some View {
        let _ = RepositoryContainer.platformRepository.register(factory: { MockPlatformRepository() })

        ForEach(ColorScheme.allCases, id: \.self) {
            PlatformsView(viewModel: PlatformsViewModel()).preferredColorScheme($0)
        }
    }
}
