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
    @State var scrollPosition = 1
    @State private var selectedPoint: AnnualGameplayProgressPoint?
    @State private var chartProxy: ChartProxy?
    @State private var visibleDomainLength = AnnualGameplayProgressChartView.defaultVisibleDomainLength
    @State private var visibleDomainLengthAtGestureStart: Int?

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

                    GeometryReader { geometryProxy in
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
                            AxisMarks(values: .stride(by: 5)) { value in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel {
                                    if let day = value.as(Int.self),
                                       let label = dayAxisLabel(forDay: day) {
                                        Text(label)
                                    }
                                }
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
                        .chartLegend(.hidden)
                        .chartScrollableAxes(.horizontal)
                        .chartXVisibleDomain(length: visibleDomainLength)
                        .chartScrollPosition(x: $scrollPosition)
                        .scrollIndicators(.hidden)
                        .chartBackground { proxy in
                            Color.clear
                                .allowsHitTesting(false)
                                .onAppear { chartProxy = proxy }
                                .onChange(of: scrollPosition) { _, _ in chartProxy = proxy }
                                .onChange(of: visibleDomainLength) { _, _ in chartProxy = proxy }
                        }
#if os(iOS)
                        .simultaneousGesture(
                            MagnifyGesture()
                                .onChanged { value in
                                    let base = visibleDomainLengthAtGestureStart ?? visibleDomainLength
                                    if visibleDomainLengthAtGestureStart == nil {
                                        visibleDomainLengthAtGestureStart = visibleDomainLength
                                    }

                                    let proposedLength = Double(base) / value.magnification
                                    visibleDomainLength = clampedVisibleDomainLength(Int(proposedLength.rounded()))
                                }
                                .onEnded { _ in
                                    visibleDomainLengthAtGestureStart = nil
                                }
                        )
                        .simultaneousGesture(
                            SpatialTapGesture()
                                .onEnded { value in
                                    selectPoint(at: value.location, geometryProxy: geometryProxy)
                                }
                        )
#endif
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

                legend
            }
            .padding()
        }
        .padding()
    }

    private var legend: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 130), alignment: .leading)],
            alignment: .leading,
            spacing: 8
        ) {
            ForEach(legendEntries, id: \.year) { entry in
                HStack(spacing: 8) {
                    Circle()
                        .fill(entry.color)
                        .frame(width: 10, height: 10)

                    Text(String(entry.year))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer(minLength: 4)

                    Text(formattedDuration(entry.totalMinutes))
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: Private

    private var gameplayPoints: [AnnualGameplayProgressPoint] {
        series
            .sorted(by: { $0.year < $1.year })
            .flatMap { $0.points }
    }

    private var legendEntries: [(year: Int, color: Color, totalMinutes: Double)] {
        series
            .sorted(by: { $0.year < $1.year })
            .map { (year: $0.year, color: color(for: $0.year), totalMinutes: $0.totalMinutes) }
    }

    private func dayAxisLabel(forDay day: Int) -> String? {
        if let referenceDate = gameplayPoints.first(where: { $0.day == day })?.referenceDate {
            return referenceDate.toFormattedString(dateFormat: "dd/MM")
        }

        guard let anchor = gameplayPoints.first,
              let date = Calendar.current.date(
                  byAdding: .day,
                  value: day - anchor.day,
                  to: anchor.referenceDate
              ) else {
            return nil
        }

        return date.toFormattedString(dateFormat: "dd/MM")
    }

    private func selectPoint(at location: CGPoint, geometryProxy: GeometryProxy) {
        guard let proxy = chartProxy else {
            selectedPoint = nil
            return
        }

        let plotFrame = geometryProxy[proxy.plotAreaFrame]

        guard plotFrame.contains(location) else {
            selectedPoint = nil
            return
        }

        let xPosition = location.x - plotFrame.origin.x
        let yPosition = location.y - plotFrame.origin.y

        guard let day: Int = proxy.value(atX: xPosition),
              let yValue: Double = proxy.value(atY: yPosition) else {
            selectedPoint = nil
            return
        }

        let candidates = gameplayPoints.filter { $0.day == day }

        selectedPoint = candidates.min(by: {
            abs($0.value - yValue) < abs($1.value - yValue)
        })
    }

    private var maxVisibleDay: Int {
        gameplayPoints.map(\.day).max() ?? 1
    }

    private static let defaultVisibleDomainLength = 15
    private static let minVisibleDomainLength = 5

    private var initialScrollPosition: Int {
        max(1, maxVisibleDay - (visibleDomainLength - 1))
    }

    private func clampedVisibleDomainLength(_ length: Int) -> Int {
        let upperBound = max(Self.minVisibleDomainLength, maxVisibleDay)
        return min(max(length, Self.minVisibleDomainLength), upperBound)
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

    private func formattedDuration(_ totalMinutes: Double) -> String {
        let minutes = Int(totalMinutes.rounded())
        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        }

        return "\(remainingMinutes)m"
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
#if os(iOS)
        .background(Color(.systemBackground).opacity(0.9))
#endif
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
