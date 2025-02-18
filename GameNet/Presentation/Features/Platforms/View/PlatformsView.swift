//
//  PlatformsView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import SwiftUI
import TTProgressHUD
import SwiftData
import GameNet_Network

// MARK: - PlatformsView

struct PlatformsView: View {
    // MARK: Internal
    @Environment(\.modelContext) private var modelContext
    
    @ObservedObject var viewModel: PlatformsViewModel
    @State var isLoading = true
    @StateObject var networkConnectivity = NetworkConnectivity()

    var body: some View {
        NavigationStack(path: $presentedPlatforms) {
            VStack {
                if let platforms = viewModel.platforms {
                    List(platforms, id: \.id) { platform in
                        #if os(iOS)
                        SwiftUI.NavigationLink(platform.name, value: platform.id)
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
                    SwiftUI.NavigationLink(value: String()) {
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
                    await viewModel.fetchData(isConnected: networkConnectivity.status == .connected)
                }
            }
        }
        .onChange(of: viewModel.state) { _, state in
            isLoading = state == .loading
        }
        .task {
            await viewModel.fetchData(isConnected: networkConnectivity.status == .connected)
        }
    }

    // MARK: Private

    @State private var presentedPlatforms = NavigationPath()
}

// MARK: - Previews

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    
    let _ = RepositoryContainer.platformRepository.register(factory: { MockPlatformRepository() })

    PlatformsView(
        viewModel: PlatformsViewModel(
            modelContext: ModelContext(
                try! ModelContainer(for: Platform.self, configurations: config)
            )
        )
    )
    .modelContainer(for: Platform.self, inMemory: true)
    .preferredColorScheme(.dark)
}
