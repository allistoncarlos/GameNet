//
//  DashboardView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import SwiftUI

// MARK: - DashboardView

struct DashboardView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: -20) {
                    playingCard

                    physicalDigitalCard

                    finishedByYearCard

                    boughtByYearCard

                    gamesByPlatformCard
                }
            }
            .navigationBarTitle("Dashboard")
            .statusBarStyle(color: .main)
        }
    }
}

extension DashboardView {
    var playingCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.primaryCardBackground)

            VStack(alignment: .leading, spacing: 20) {
                VStack {
                    Text("Jogando")
                }
            }
            .padding()
            .padding(.trailing, 55)
        }
        .padding()
    }
}

extension DashboardView {
    var physicalDigitalCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.secondaryCardBackground)

            VStack(alignment: .leading, spacing: 20) {
                VStack {
                    Text("486 Jogos")
                }
            }
            .padding()
            .padding(.trailing, 55)
        }
        .padding()
    }
}

extension DashboardView {
    var finishedByYearCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.tertiaryCardBackground)

            VStack(alignment: .leading, spacing: 20) {
                VStack {
                    Text("Jogando")
                }
            }
            .padding()
            .padding(.trailing, 55)
        }
        .padding()
    }
}

extension DashboardView {
    var boughtByYearCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.tertiaryCardBackground)

            VStack(alignment: .leading, spacing: 20) {
                VStack {
                    Text("Jogando")
                }
            }
            .padding()
            .padding(.trailing, 55)
        }
        .padding()
    }
}

extension DashboardView {
    var gamesByPlatformCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.tertiaryCardBackground)

            VStack(alignment: .leading, spacing: 20) {
                VStack {
                    Text("Jogando")
                }
            }
            .padding()
            .padding(.trailing, 55)
        }
        .padding()
    }
}

// MARK: - DashboardView_Previews

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            DashboardView().preferredColorScheme($0)
        }
    }
}
