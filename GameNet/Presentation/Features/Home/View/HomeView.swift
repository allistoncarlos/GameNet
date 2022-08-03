//
//  HomeView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 30/07/22.
//

import SwiftUI

// MARK: - HomeView

struct HomeView: View {
    // MARK: Lifecycle

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel

        UITabBar.appearance().backgroundColor = UIColor(.main)
    }

    // MARK: Internal

    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "display")
                }

            GamesView()
                .tabItem {
                    Label("Games", systemImage: "gamecontroller")
                }

            PlatformsView()
                .tabItem {
                    Label("Plataformas", systemImage: "laptopcomputer")
                }

            ListsView()
                .tabItem {
                    Label("Listas", systemImage: "list.bullet.rectangle.portrait")
                }
        }
        .foregroundColor(.accentColor)
    }
}

// MARK: - HomeView_Previews

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            HomeView(viewModel: HomeViewModel()).preferredColorScheme($0)
        }
    }
}
