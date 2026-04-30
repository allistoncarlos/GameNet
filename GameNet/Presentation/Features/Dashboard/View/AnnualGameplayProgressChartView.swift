//
//  AnnualGameplayProgressChartView.swift
//  GameNet
//
//  Created by AI Assistant on 23/04/26.
//

import Charts
import SwiftUI

// MARK: - AnnualGameplayProgressChartView

struct AnnualGameplayProgressChartView: View {

    // MARK: Internal

    let series: [AnnualGameplayProgressSeries]
    @State var selectedPoint: AnnualGameplayProgressPoint? = nil
    @State var scrollPosition = 1

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.primaryCardBackground)

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                        .font(.cardTitle)

                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    GeometryReader { _ in
                        Chart(gameplayPoints) { point in
                            LineMark(
                                x: .value("Dia", point.day),
                                y: .value("Minutos", point.value)
                            )
                            .foregroundStyle(by: .value("Ano", point.yearLabel))
                            .lineStyle(StrokeStyle(lineWidth: 2))
                            .symbol(.circle)
                        }
                        .chartForegroundStyleScale(
                            domain: yearColors.map { $0.0 },
                            range: yearColors.map { $0.1 }
                        )
                        .chartXAxis {
                            AxisMarks(values: .stride(by: 5)) { _ in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel()
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { value in
                                AxisGridLine()
                                AxisValueLabel {
                                    if let minutes = value.as(Double.self) {
                                        Text("\(formattedMinutes(minutes)) min")
                                    }
                                }
                            }
                        }
                        .chartScrollableAxes(.horizontal)
                        .chartXVisibleDomain(length: 15)
                        .chartScrollPosition(x: $scrollPosition)
                        .chartOverlay { proxy in
                            GeometryReader { geometryProxy in
                                Rectangle()
                                    .fill(.clear)
                                    .contentShape(Rectangle())
                                    .simultaneousGesture(
                                        SpatialTapGesture()
                                            .onEnded { value in
                                                let plotFrame = geometryProxy[proxy.plotAreaFrame]

                                                guard plotFrame.contains(value.location) else {
                                                    selectedPoint = nil
                                                    return
                                                }

                                                let xPosition = value.location.x - plotFrame.origin.x
                                                let yPosition = value.location.y - plotFrame.origin.y

                                                guard let day: Int = proxy.value(atX: xPosition),
                                                      let yValue: Double = proxy.value(atY: yPosition) else {
                                                    selectedPoint = nil
                                                    return
                                                }

                                                let candidates = gameplayPoints.filter { $0.day == day }

                                                guard let closest = candidates.min(by: {
                                                    abs($0.value - yValue) < abs($1.value - yValue)
                                                }) else {
                                                    selectedPoint = nil
                                                    return
                                                }

                                                selectedPoint = closest
                                            }
                                    )
                            }
                        }
                        .overlay(alignment: .topLeading) {
                            if let selectedPoint {
                                AnnualGameplayChartHintView(
                                    title: "Dia \(selectedPoint.dayLabel) - \(selectedPoint.yearLabel)",
                                    value: selectedPoint.value
                                )
                                .padding(8)
                            }
                        }
                        .onAppear {
                            scrollPosition = initialScrollPosition
                        }
                        .onChange(of: maxVisibleDay) { _, _ in
                            scrollPosition = initialScrollPosition
                        }
                    }
                }
                .frame(height: 300)
            }
            .padding()
        }
        .padding()
    }

    // MARK: Private

    private var gameplayPoints: [AnnualGameplayProgressPoint] {
        series
            .sorted(by: { $0.year < $1.year })
            .flatMap { $0.points }
    }

    private var maxVisibleDay: Int {
        gameplayPoints.map(\.day).max() ?? 1
    }

    private var initialScrollPosition: Int {
        max(1, maxVisibleDay - 14)
    }

    private var title: String {
        guard let firstYear = series.map(\.year).min(),
              let lastYear = series.map(\.year).max() else {
            return "Evolução Anual"
        }

        return "Evolução Anual (\(firstYear)-\(lastYear))"
    }

    private var subtitle: String? {
        guard let lastDate = series.first(where: { !$0.points.isEmpty })?.points.last?.referenceDate else {
            return nil
        }

        return "Minutos acumulados de 01/01 a \(lastDate.toFormattedString(dateFormat: "dd/MM")) de cada ano"
    }

    private var yearColors: [(String, Color)] {
        let years = Set(gameplayPoints.map(\.year)).sorted()

        return years.map { year in
            (String(year), color(for: year))
        }
    }

    private func color(for year: Int) -> Color {
        let palette: [Color] = [
            Color.orange,
            Color.yellow,
            Color.green,
            Color.blue,
            Color.pink,
            Color.purple,
        ]

        let index = max(0, year - 2021) % palette.count
        return palette[index]
    }

    private func formattedMinutes(_ value: Double) -> String {
        if value.rounded() == value {
            return String(format: "%.0f", value)
        }

        return String(format: "%.1f", value)
    }
}

// MARK: - AnnualGameplayChartHintView

struct AnnualGameplayChartHintView: View {
    let title: String
    let value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)

            Text("Minutos: \(formattedMinutes(value)) min")
                .font(.caption)
                .foregroundColor(.main)
        }
        .padding(8)
        .background(Color(.systemBackground).opacity(0.9))
        .cornerRadius(8)
        .shadow(radius: 4)
    }

    private func formattedMinutes(_ value: Double) -> String {
        if value.rounded() == value {
            return String(format: "%.0f", value)
        }

        return String(format: "%.1f", value)
    }
}

// MARK: - Previews

#Preview("Annual Gameplay Progress") {
    let calendar = Calendar.current
    let currentYear = calendar.component(.year, from: Date.timeZoneDate())

    let sampleSeries = (2021 ... currentYear).map { year in
        let startDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) ?? Date()
        let points = (0 ..< 10).compactMap { dayOffset -> AnnualGameplayProgressPoint? in
            guard
                let date = calendar.date(byAdding: .day, value: dayOffset * 8, to: startDate),
                let referenceDate = calendar.date(
                    from: DateComponents(
                        year: currentYear,
                        month: calendar.component(.month, from: date),
                        day: calendar.component(.day, from: date)
                    )
                )
            else {
                return nil
            }

            return AnnualGameplayProgressPoint(
                year: year,
                day: dayOffset + 1,
                date: date,
                referenceDate: referenceDate,
                cumulativeMinutes: Double((dayOffset + 1) * (year - 2019) * 35)
            )
        }

        return AnnualGameplayProgressSeries(
            year: year,
            points: points,
            totalMinutes: points.last?.cumulativeMinutes ?? 0
        )
    }

    AnnualGameplayProgressChartView(series: sampleSeries)
        .preferredColorScheme(.dark)
}
