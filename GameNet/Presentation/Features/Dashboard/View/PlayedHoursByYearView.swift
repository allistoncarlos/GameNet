//
//  PlayedHoursByYearView.swift
//  GameNet
//
//  Created by AI Assistant
//

import SwiftUI

// MARK: - PlayedHoursByYearView

struct PlayedHoursByYearView: View {

    // MARK: Internal

    let gameplaySessions: [Int: GameplaySessions]
    let onYearTapped: (GameplaySessionNavigation) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(sortedYears, id: \.key) { key, session in
                    yearTile(year: key, session: session)
                }
            }

            if !sortedYears.isEmpty {
                averageFooter
            }
        }
        .foregroundStyle(.white)
        .padding(20)
        .glassEffect(
            .regular.tint(Color.secondaryCardBackground),
            in: .rect(cornerRadius: 20)
        )
        .padding()
    }

    // MARK: Private

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    private var sortedYears: [(key: Int, value: GameplaySessions)] {
        gameplaySessions
            .sorted { $0.key >= $1.key }
            .map { (key: $0.key, value: $0.value) }
    }

    private var totalMinutes: Int {
        sortedYears.reduce(0) { $0 + minutes(from: $1.value.totalGameplayTime) }
    }

    private var header: some View {
        Text("Horas Jogadas por Ano")
            .font(.cardTitle)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var averageFooter: some View {
        HStack {
            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "chart.bar.fill")
                    .font(.dashboardGameSubtitle)
                Text("Média de \(formatted(minutes: totalMinutes / sortedYears.count)) por ano")
                    .font(.dashboardGameSubtitle)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .glassEffect(
                .regular.tint(.white.opacity(0.18)),
                in: .capsule
            )

            Spacer()
        }
    }

    private func yearTile(year: Int, session: GameplaySessions) -> some View {
        Button {
            onYearTapped(GameplaySessionNavigation(key: year, value: session))
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.dashboardGameSubtitle)
                    Text(String(year))
                        .font(.dashboardGameSubtitle)
                    Spacer()
                }

                Text(session.totalGameplayTime)
                    .font(.dashboardGameTitle)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.white.opacity(0.15))
            )
            .contentShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private func minutes(from time: String) -> Int {
        let components = time.split(separator: ":")
        guard components.count == 2,
              let hours = Int(components[0]),
              let minutes = Int(components[1]) else {
            return 0
        }

        return hours * 60 + minutes
    }

    private func formatted(minutes totalMinutes: Int) -> String {
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        return "\(hours):\(String(format: "%02d", minutes))"
    }
}

// MARK: - Preview

#Preview("Played Hours") {
    let sample: [Int: GameplaySessions] = [
        2024: GameplaySessions(id: "2024", sessions: [], totalGameplayTime: "182:30", averageGameplayTime: "02:10"),
        2023: GameplaySessions(id: "2023", sessions: [], totalGameplayTime: "150:45", averageGameplayTime: "01:55"),
        2022: GameplaySessions(id: "2022", sessions: [], totalGameplayTime: "98:20", averageGameplayTime: "01:30"),
        2021: GameplaySessions(id: "2021", sessions: [], totalGameplayTime: "120:00", averageGameplayTime: "01:40"),
        2020: GameplaySessions(id: "2020", sessions: [], totalGameplayTime: "75:10", averageGameplayTime: "01:20"),
        2019: GameplaySessions(id: "2019", sessions: [], totalGameplayTime: "60:05", averageGameplayTime: "01:05")
    ]

    ScrollView {
        PlayedHoursByYearView(
            gameplaySessions: sample,
            onYearTapped: { _ in }
        )
    }
    .preferredColorScheme(.dark)
}
