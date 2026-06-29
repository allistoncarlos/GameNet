//
//  FinishedByYearTimelineView.swift
//  GameNet
//
//  Created by AI Assistant
//

import SwiftUI

// MARK: - FinishedByYearTimelineView

struct FinishedByYearTimelineView: View {

    // MARK: Internal

    let finishedGamesByYear: [FinishedGameByYearTotal]
    let onYearTapped: (FinishedGameByYearTotal) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header

            GlassEffectContainer(spacing: 12) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(displayedGames.enumerated()), id: \.element.year) { index, finishedGame in
                        TimelineItemView(
                            finishedGame: finishedGame,
                            isFirst: index == 0,
                            isLast: index == displayedGames.count - 1,
                            isHighlighted: index == 0,
                            onTapped: {
                                onYearTapped(finishedGame)
                            }
                        )
                    }
                }
            }

            if finishedGamesByYear.count > collapsedCount {
                expanderButton
            }
        }
        .foregroundStyle(.white)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.tertiaryCardBackground)
        )
        .padding()
    }

    // MARK: Private

    @State private var isExpanded = false

    private let collapsedCount = 3

    private var displayedGames: [FinishedGameByYearTotal] {
        if isExpanded {
            return finishedGamesByYear
        }

        return Array(finishedGamesByYear.prefix(collapsedCount))
    }

    private var totalFinished: Int {
        finishedGamesByYear.reduce(0) { $0 + $1.total }
    }

    private var expanderButton: some View {
        Button {
            withAnimation(.snappy) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 6) {
                Text(isExpanded ? "Ver menos" : "Ver todos os \(finishedGamesByYear.count) anos")
                    .font(.dashboardGameSubtitle)

                Image(systemName: "chevron.down")
                    .font(.dashboardGameSubtitle)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .foregroundStyle(.white)
            .opacity(0.85)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Finalizados por Ano")
                .font(.cardTitle)
            Text("\(totalFinished) jogos no total")
                .font(.dashboardGameSubtitle)
                .opacity(0.85)
        }
    }
}

// MARK: - TimelineItemView

struct TimelineItemView: View {

    // MARK: Internal

    let finishedGame: FinishedGameByYearTotal
    let isFirst: Bool
    let isLast: Bool
    let isHighlighted: Bool
    let onTapped: () -> Void

    var body: some View {
        Button(action: onTapped) {
            HStack(spacing: 14) {
                railView

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(String(finishedGame.year))
                        .font(.dashboardGameTitle)

                    Text("\(finishedGame.total) jogos")
                        .font(.dashboardGameSubtitle)
                        .opacity(0.7)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.dashboardGameSubtitle)
                        .opacity(0.4)
                }
            }
            .frame(height: rowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: Private

    private let rowHeight: CGFloat = 50
    private let badgeSize: CGFloat = 36

    private var railView: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(.white.opacity(0.22))
                .frame(width: 2)
                .frame(maxHeight: .infinity)
                .opacity(isFirst ? 0 : 1)

            badge

            Rectangle()
                .fill(.white.opacity(0.22))
                .frame(width: 2)
                .frame(maxHeight: .infinity)
                .opacity(isLast ? 0 : 1)
        }
        .frame(width: badgeSize)
    }

    private var badge: some View {
        Text("\(finishedGame.total)")
            .font(.dashboardGameSubtitle)
            .foregroundStyle(.white)
            .frame(width: badgeSize, height: badgeSize)
            .glassEffect(
                .regular.tint(Color.main.opacity(isHighlighted ? 0.8 : 0.45)),
                in: Circle()
            )
            .overlay(
                Circle()
                    .stroke(.white.opacity(isHighlighted ? 0.9 : 0.0), lineWidth: 2)
            )
    }
}

// MARK: - Preview

#Preview("Timeline View") {
    let sampleData = [
        FinishedGameByYearTotal(year: 2024, total: 15),
        FinishedGameByYearTotal(year: 2023, total: 12),
        FinishedGameByYearTotal(year: 2022, total: 8),
        FinishedGameByYearTotal(year: 2021, total: 10),
        FinishedGameByYearTotal(year: 2020, total: 6),
        FinishedGameByYearTotal(year: 2019, total: 4),
        FinishedGameByYearTotal(year: 2018, total: 7),
        FinishedGameByYearTotal(year: 2017, total: 3),
        FinishedGameByYearTotal(year: 2016, total: 5),
        FinishedGameByYearTotal(year: 2015, total: 2)
    ]

    ScrollView {
        FinishedByYearTimelineView(
            finishedGamesByYear: sampleData,
            onYearTapped: { _ in }
        )
    }
    .preferredColorScheme(.dark)
}

#Preview("Timeline View Light") {
    let sampleData = [
        FinishedGameByYearTotal(year: 2024, total: 15),
        FinishedGameByYearTotal(year: 2023, total: 12),
        FinishedGameByYearTotal(year: 2022, total: 8),
        FinishedGameByYearTotal(year: 2021, total: 10),
        FinishedGameByYearTotal(year: 2020, total: 6)
    ]

    ScrollView {
        FinishedByYearTimelineView(
            finishedGamesByYear: sampleData,
            onYearTapped: { _ in }
        )
    }
    .preferredColorScheme(.light)
}
