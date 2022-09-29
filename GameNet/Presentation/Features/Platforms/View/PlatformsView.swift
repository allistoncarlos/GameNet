//
//  PlatformsView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import SwiftUI

// MARK: - PlatformsView

struct PlatformsView: View {
    @ObservedObject var viewModel: PlatformsViewModel

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.uiState == .loading {
                    ProgressView()
                } else {
                    if let platforms = viewModel.platforms {
                        List(platforms, id: \.id) { platform in
                            NavigationLink(destination: viewModel.editPlatformView(platform: platform)) {
                                Text(platform.name)
                            }
                        }
                    }
                }
            }
            .navigationView(title: "Platformas")
            .toolbar {
                Button(action: {}) {
                    NavigationLink(destination: viewModel.editPlatformView()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .task {
            await viewModel.fetchData()
        }
    }
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
