//
//  ListDetailsView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 14/01/23.
//

import SwiftUI
import TTProgressHUD

// MARK: - ListDetailsView

struct ListDetailsView: View {
    @StateObject var viewModel: ListDetailsViewModel
    @Binding var navigationPath: NavigationPath
    @State var isLoading = true

    var body: some View {
        NavigationView {
            Form {
                Section {
                    if let listGame = viewModel.listGame {
                        viewModel.showListGamesView(
                            navigationPath: $navigationPath,
                            listGame: listGame
                        )
                        .deleteDisabled(true)
                        .moveDisabled(true)
                    }
                }
            }
            .disabled(isLoading)
        }
        .overlay {
            TTProgressHUD($isLoading, config: GameNetApp.hudConfig)
        }
        .onChange(of: viewModel.state) { _, state in
            isLoading = state == .loading
        }
        .navigationView(title: viewModel.name)
        .task {
            await viewModel.fetchData()
        }
    }
}

// MARK: - Previews

#Preview("Dark Mode") {
    ListDetailsView(
        viewModel: ListDetailsViewModel(
            originFlow: .finishedByYear(2023)
        ),
        navigationPath: .constant(NavigationPath())
    ).preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    ListDetailsView(
        viewModel: ListDetailsViewModel(
            originFlow: .finishedByYear(2023)
        ),
        navigationPath: .constant(NavigationPath())
    ).preferredColorScheme(.light)
}
