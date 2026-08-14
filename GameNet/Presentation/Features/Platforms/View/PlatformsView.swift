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
    @State private var search: String = ""
    @State private var presentedPlatforms = NavigationPath()

    var body: some View {
        NavigationStack(path: $presentedPlatforms) {
            GeometryReader { geometry in
                let columns = PlatformMetrics.gameGridColumns(for: geometry.size.width)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(displayedPlatforms, id: \.id) { platform in
                            if let platformId = platform.id {
                                SwiftUI.NavigationLink(value: PlatformRoute.detail(id: platformId)) {
                                    PlatformItemView(
                                        name: platform.name,
                                        imageURL: PlatformIllustration.url(for: platform.name)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(maxWidth: PlatformMetrics.contentMaxWidth(for: geometry.size.width))
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, PlatformMetrics.horizontalPadding(for: geometry.size.width))
                }
            }
            .disabled(isLoading)
            .navigationDestination(for: PlatformRoute.self) { route in
                switch route {
                case .create:
                    viewModel.createPlatformView(navigationPath: $presentedPlatforms)
                case let .detail(platformId):
                    viewModel.platformDetailView(
                        navigationPath: $presentedPlatforms,
                        platformId: platformId
                    )
                }
            }
            .searchable(
                text: $search,
                prompt: Text("Buscar")
            )
            .navigationView(title: "Plataformas")
            .toolbar {
                Button(action: {}) {
                    SwiftUI.NavigationLink(value: PlatformRoute.create) {
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

    private var displayedPlatforms: [Platform] {
        let platforms = viewModel.platforms ?? []
        guard !search.isEmpty else { return platforms }
        return platforms.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }
}
