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

            VStack(alignment: .leading, spacing: 15) {
                VStack {
                    Text("Jogando")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                        .font(.cardTitle)
                }

                VStack(alignment: .leading) {
                    Text("Doom Troopers")
                        .font(.dashboardGameTitle)
                    Text("16/01/2022")
                        .font(.dashboardGameSubtitle)
                }

                VStack(alignment: .leading) {
                    Text("The Legend of Zelda: Breath of the Wild")
                        .font(.dashboardGameTitle)
                    Text("11/10/2021")
                        .font(.dashboardGameSubtitle)
                }
            }
            .padding()
        }
        .padding()
    }
}

extension DashboardView {
    var physicalDigitalCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.secondaryCardBackground)

            VStack(alignment: .leading, spacing: 5) {
                VStack {
                    Text("486 Jogos")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                        .font(.cardTitle)
                }

                Text("R$ 9.153,87")
                    .font(.dashboardGameSubtitle)

                VStack(alignment: .leading) {
                    Text("271 Digitais")
                        .font(.dashboardGameTitle)
                    Text("111 Físicos")
                        .font(.dashboardGameTitle)
                }
            }
            .padding()
        }
        .padding()
    }
}

extension DashboardView {
    var finishedByYearCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.tertiaryCardBackground)

            VStack(alignment: .leading, spacing: 15) {
                VStack {
                    Text("Finalizados por Ano")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                        .font(.cardTitle)
                }

                VStack(alignment: .leading) {
                    HStack(spacing: 20) {
                        Text("03")
                            .font(.dashboardGameTitle)
                        Text("2022")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }

                    HStack(spacing: 20) {
                        Text("03")
                            .font(.dashboardGameTitle)
                        Text("2022")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }

                    HStack(spacing: 20) {
                        Text("07")
                            .font(.dashboardGameTitle)
                        Text("2021")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }

                    HStack(spacing: 20) {
                        Text("07")
                            .font(.dashboardGameTitle)
                        Text("2020")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }

                    HStack(spacing: 20) {
                        Text("04")
                            .font(.dashboardGameTitle)
                        Text("2019")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }

                    HStack(spacing: 20) {
                        Text("10")
                            .font(.dashboardGameTitle)
                        Text("2018")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }

                    HStack(spacing: 20) {
                        Text("07")
                            .font(.dashboardGameTitle)
                        Text("2017")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }

                    HStack(spacing: 20) {
                        Text("14")
                            .font(.dashboardGameTitle)
                        Text("2016")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }
                }
            }
            .padding()
        }
        .padding()
    }
}

extension DashboardView {
    var boughtByYearCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.tertiaryCardBackground)

            VStack(alignment: .leading, spacing: 15) {
                VStack {
                    Text("Comprados por Ano")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                        .font(.cardTitle)
                }

                VStack(alignment: .leading) {
                    HStack(spacing: 20) {
                        Text("03")
                            .font(.dashboardGameTitle)
                        Text("2022")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }

                    HStack(spacing: 20) {
                        Text("03")
                            .font(.dashboardGameTitle)
                        Text("2022")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }

                    HStack(spacing: 20) {
                        Text("07")
                            .font(.dashboardGameTitle)
                        Text("2021")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }

                    HStack(spacing: 20) {
                        Text("07")
                            .font(.dashboardGameTitle)
                        Text("2020")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }

                    HStack(spacing: 20) {
                        Text("04")
                            .font(.dashboardGameTitle)
                        Text("2019")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }

                    HStack(spacing: 20) {
                        Text("10")
                            .font(.dashboardGameTitle)
                        Text("2018")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }

                    HStack(spacing: 20) {
                        Text("07")
                            .font(.dashboardGameTitle)
                        Text("2017")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }

                    HStack(spacing: 20) {
                        Text("14")
                            .font(.dashboardGameTitle)
                        Text("2016")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }
                }
            }
            .padding()
        }
        .padding()
    }
}

extension DashboardView {
    var gamesByPlatformCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.tertiaryCardBackground)

            VStack(alignment: .leading, spacing: 15) {
                VStack {
                    Text("Jogos por Plataforma")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                        .font(.cardTitle)
                }

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 20) {
                        Text("83")
                            .font(.dashboardGameTitle)
                        Text("Playstation 4")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }

                    HStack(spacing: 20) {
                        Text("12")
                            .font(.dashboardGameTitle)
                        Text("Nintendo WiiU (Virtual Console)")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }

                    HStack(spacing: 20) {
                        Text("18")
                            .font(.dashboardGameTitle)
                        Text("Nintendo WiiU")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }

                    HStack(spacing: 20) {
                        Text("47")
                            .font(.dashboardGameTitle)
                        Text("PlayStation Vita")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }

                    HStack(spacing: 20) {
                        Text("03")
                            .font(.dashboardGameTitle)
                        Text("Nintendo 3DS (3D Classics)")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }

                    HStack(spacing: 20) {
                        Text("18")
                            .font(.dashboardGameTitle)
                        Text("Nintendo 3DS")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }

                    HStack(spacing: 20) {
                        Text("08")
                            .font(.dashboardGameTitle)
                        Text("Nintendo 3DS (Virtual Console)")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }

                    HStack(spacing: 20) {
                        Text("38")
                            .font(.dashboardGameTitle)
                        Text("Nintendo Wii")
                            .font(.dashboardGameTitle)
                        Spacer()
                    }
                }
            }
            .padding()
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
