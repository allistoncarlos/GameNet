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
                            NavigationLink(value: platform.id) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Image(systemName: "dpad.down.fill").foregroundColor(.blue).font(.system(size: 30)).padding(.top, 5)
                                    Text(platform.name).bold().padding(.top, 5)
                                }.padding()
                            }

                        }.listStyle(CarouselListStyle())
                    }
                }
            }
        }
        .onChange(of: presentedPlatforms) { _, newValue in
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

// MARK: - Previews

#Preview {
    PlayingGamesView(viewModel: PlayingGamesViewModel())
}
