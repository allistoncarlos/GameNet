//
//  GameplaySessionDetailView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 27/02/23.
//

import CachedAsyncImage
import GameNet_Network
import SwiftUI

// MARK: - GameplaySessionCell

struct GameplaySessionCell: View {
    var gameName: String?
    var gameCover: String?
    var startDate: String?
    var finishDate: String?
    var totalGameplayTime: String?

    var body: some View {
        HStack(spacing: 16) {
            if let gameCover {
                CachedAsyncImage(url: URL(string: gameCover)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: { ProgressView().progressViewStyle(.circular) }
                    .frame(height: 80)
            }

            VStack {
                Text(gameName ?? "")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.dashboardGameTitle)

                HStack(spacing: 0) {
                    if let startDate {
                        Text(startDate)
                            .font(.dashboardGameSubtitle)

                        if let finishDate {
                            Text(" até \(finishDate)")
                                .font(.dashboardGameSubtitle)
                        }

                        if let totalGameplayTime {
                            Text(" (\(totalGameplayTime))")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.dashboardGameSubtitle)
                        }

                        Spacer()
                    }
                }
            }
        }
        .padding(16)
        .frame(height: 116)
        .background(.tertiary)
        .cornerRadius(8)
    }
}

// MARK: - GameplaySessionDetailView

struct GameplaySessionDetailView: View {
    @ObservedObject var viewModel: GameplaySessionDetailViewModel

    @Binding var navigationPath: NavigationPath

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                GameplayChartView(
                    data: $viewModel.chartGameplaySession,
                    recentRegister: $viewModel.recentRegister
                )
                .frame(height: 320)

                ForEach(
                    viewModel.groupedGameplaySession.sorted(by: { $0.key > $1.key }),
                    id: \.key
                ) { date, sessions in
                    Text(date.toFormattedString(dateFormat: GameNetApp.dateFormat))
                        .font(.dashboardGameTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(sessions, id: \.?.id) { session in
                        NavigationLink(value: session) {
                            GameplaySessionCell(
                                gameName: session?.gameName,
                                gameCover: session?.gameCover,
                                startDate: session?.start.toFormattedString(dateFormat: GameNetApp.timeFormat),
                                finishDate: session?.finish?.toFormattedString(dateFormat: GameNetApp.timeFormat),
                                totalGameplayTime: session?.totalGameplayTime
                            )
                            .multilineTextAlignment(.leading)
                        }
                    }
                }
            }
            .padding(10)
        }
        .navigationView(title: viewModel.title)
    }

}

// MARK: - GameplaySessionDetailView_Previews

struct GameplaySessionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sessions = MockGameRepository().fetchGameplaySessions(id: "1")!

        let gameplaySessionNavigation = GameplaySessionNavigation(
            key: 2023,
            value: sessions
        )

        let viewModel = GameplaySessionDetailViewModel(gameplaySession: gameplaySessionNavigation)

        GameplaySessionDetailView(
            viewModel: viewModel,
            navigationPath: .constant(NavigationPath())
        )
    }
}
