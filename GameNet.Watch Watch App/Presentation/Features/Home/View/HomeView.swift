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
        switch viewModel.state {
        case .idle:
            NotLoggedView()
                .onAppear {
                    viewModel.askForCredentials()
                }
        case .askingForCredentials:
            Text("PEDINDO CREDENCIAIS")
        case .notLogged:
            Text("PRECISA LOGAR NO IPHONE")
        case .logged:
            PlayingGamesView(viewModel: PlayingGamesViewModel())
        }
    }
}

// MARK: - HomeView_Previews

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: HomeViewModel())
    }
}
