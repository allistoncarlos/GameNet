//
//  HomeView.swift
//  GameNet.Watch Watch App
//
//  Created by Alliston Aleixo on 10/01/23.
//

import SwiftUI

// MARK: - HomeView

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        if viewModel.hasValidAccessToken {
            PlayingGamesView(viewModel: PlayingGamesViewModel())
        } else {
            NotLoggedView()
        }
    }
}

// MARK: - HomeView_Previews

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: HomeViewModel())
    }
}
