//
//  ListDetailsView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 14/01/23.
//

import SwiftUI

// MARK: - ListDetailsView

struct ListDetailsView: View {
    @StateObject var viewModel: ListDetailsViewModel
    @Binding var navigationPath: NavigationPath

    var body: some View {
        VStack {
            if viewModel.state == .loading {
                ProgressView()
            } else {
                if let listGame = viewModel.listGame {
                    viewModel.showListGamesView(
                        navigationPath: $navigationPath,
                        listGame: listGame
                    )
                }
            }
        }
        .navigationView(title: viewModel.name)
        .task {
            await viewModel.fetchData()
        }
    }
}

// MARK: - ListDetailsView_Previews

struct ListDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ListDetailsView(
            viewModel: ListDetailsViewModel(
                originFlow: .finishedByYear(2023)
            ),
            navigationPath: .constant(NavigationPath())
        )
    }
}
