//
//  BoughtByYearView.swift
//  GameNet
//
//  Created by AI Assistant
//

import SwiftUI

// MARK: - BoughtByYearView

struct BoughtByYearView: View {

    // MARK: Internal

    let boughtByYear: [BoughtGamesByYearTotal]
    let onYearTapped: (BoughtGamesByYearTotal) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header

            GlassEffectContainer(spacing: 12) {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(displayedItems.enumerated()), id: \.element.year) { index, item in
                        yearCard(item, isHighlighted: index == 0)
                    }
                }
            }

            if sortedItems.count > collapsedCount {
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

    private let collapsedCount = 4

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    private var sortedItems: [BoughtGamesByYearTotal] {
        boughtByYear.sorted { $0.year > $1.year }
    }

    private var displayedItems: [BoughtGamesByYearTotal] {
        isExpanded ? sortedItems : Array(sortedItems.prefix(collapsedCount))
    }

    private var header: some View {
        Text("Comprados por Ano")
            .font(.cardTitle)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func yearCard(_ item: BoughtGamesByYearTotal, isHighlighted: Bool) -> some View {
        Button {
            onYearTapped(item)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(String(item.year))
                        .font(.dashboardGameTitle)

                    Spacer()

                    Image(systemName: "cart.fill")
                        .font(.dashboardGameSubtitle)
                        .opacity(0.6)
                }

                Spacer(minLength: 12)

                Text("\(item.quantity)")
                    .font(.cardTitle)
                Text("jogos")
                    .font(.dashboardGameSubtitle)
                    .opacity(0.7)

                if let formattedTotal = item.total.toCurrencyString() {
                    Text(formattedTotal)
                        .font(.dashboardGameSubtitle)
                        .opacity(0.7)
                        .padding(.top, 8)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
            .padding(16)
            .glassEffect(
                .regular.tint(isHighlighted ? Color.main.opacity(0.35) : .white.opacity(0.12)),
                in: .rect(cornerRadius: 18)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.white.opacity(isHighlighted ? 0.85 : 0.0), lineWidth: 2)
            )
            .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }

    private var expanderButton: some View {
        Button {
            withAnimation(.snappy) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 6) {
                Text(isExpanded ? "Ver menos" : "Ver todos os \(sortedItems.count) anos")
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
}

// MARK: - Preview

#Preview("Bought By Year") {
    let sample = [
        BoughtGamesByYearTotal(year: 2024, total: 1850.90, quantity: 24),
        BoughtGamesByYearTotal(year: 2023, total: 1320.00, quantity: 18),
        BoughtGamesByYearTotal(year: 2022, total: 980.50, quantity: 12),
        BoughtGamesByYearTotal(year: 2021, total: 2100.00, quantity: 30),
        BoughtGamesByYearTotal(year: 2020, total: 760.00, quantity: 9),
        BoughtGamesByYearTotal(year: 2019, total: 540.25, quantity: 7)
    ]

    ScrollView {
        BoughtByYearView(
            boughtByYear: sample,
            onYearTapped: { _ in }
        )
    }
    .preferredColorScheme(.dark)
}
