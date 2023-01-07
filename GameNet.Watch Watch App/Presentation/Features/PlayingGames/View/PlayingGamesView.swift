//
//  PlayingGamesView.swift
//  GameNet.Watch Watch App
//
//  Created by Alliston Aleixo on 06/01/23.
//

import SwiftUI

// MARK: - PlayingGamesView

struct PlayingGamesView: View {

    // MARK: Internal

    @ObservedObject var viewModel: PlayingGamesViewModel

    var body: some View {
        NavigationStack(path: $presentedPlatforms) {
            VStack {
                if viewModel.uiState == .loading {
                    ProgressView()
                } else {
                    if let platforms = viewModel.platforms {
                        List(platforms, id: \.id) { platform in
                            NavigationLink(platform.name, value: platform.id)
                        }
                    }
                }
            }
//            .navigationDestination(for: String.self) { platformId in
//                viewModel.editPlatformView(navigationPath: $presentedPlatforms, platformId: platformId)
//            }
//            .navigationView(title: "Platformas")
            .toolbar {
                Button(action: {}) {
                    NavigationLink(value: String()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .onChange(of: presentedPlatforms) { newValue in
            if newValue.isEmpty {
                Task {
                    await viewModel.fetchData()
                }
            }
        }
        .task {
            await viewModel.fetchData()
        }
    }

    // MARK: Private

    @State private var presentedPlatforms = NavigationPath()
}

// MARK: - PlayingGamesView_Previews

struct PlayingGamesView_Previews: PreviewProvider {
    static var previews: some View {
        PlayingGamesView(viewModel: PlayingGamesViewModel())
    }
}
