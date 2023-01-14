//
//  ListDetailsView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 14/01/23.
//

import SwiftUI

// MARK: - ListDetailsView

struct ListDetailsView: View {
    @ObservedObject var viewModel: ListDetailsViewModel
    @Binding var navigationPath: NavigationPath

    var body: some View {
        self.showListGamesView(originFlow: viewModel.originFlow)
            .navigationView(title: viewModel.name)
    }

    func showListGamesView(originFlow: ListOriginFlow) -> some View {
        let viewModel = ListGamesViewModel(originFlow: originFlow)

        return ListGamesView(viewModel: viewModel)
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
