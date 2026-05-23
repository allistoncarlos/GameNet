//
//  HomeView.swift
//  GameNet.Watch Watch App
//
//  Created by Alliston Aleixo on 10/01/23.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        PlayingGamesView(viewModel: PlayingGamesViewModel())
    }
}

#Preview {
    HomeView()
}
