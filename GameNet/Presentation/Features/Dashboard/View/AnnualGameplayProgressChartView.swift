//
//  AnnualGameplayProgressChartView.swift
//  GameNet
//
//  Created by AI Assistant on 23/04/26.
//

import Charts
import Factory
import SwiftUI

// MARK: - AnnualGameplayProgressChartView

struct AnnualGameplayProgressChartView: View {

    // MARK: Internal

    let series: [AnnualGameplayProgressSeries]
    var chartHeight: CGFloat = 340
    @State var scrollPosition = 1
    @State private var selectedPoint: AnnualGameplayProgressPoint?
    @State private var chartProxy: ChartProxy?
    @State private var visibleDomainLength = AnnualGameplayProgressChartView.defaultVisibleDomainLength
    @State private var visibleDomainLengthAtGestureStart: Int?
    @State private var hiddenYears: Set<Int> = []
    @State private var scrollableYDomain: ClosedRange<Double> = 0 ... 100
    @Injected(\.persistence) private var persistence: PersistenceManagerProtocol

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
                        gameplayChart(in: geometryProxy)
                    }
                }
                .frame(height: chartHeight)

                Text("Toque em um ano na legenda para ocultar/mostrar")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                legend
            }
            .padding()
        }
        .dashboardOuterPadding()
        .onAppear {
            restorePersistedPreferences()
        }
    }

    private var legend: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 130), alignment: .leading)],
            alignment: .leading,
            spacing: 8
        ) {
            ForEach(legendEntries, id: \.year) { entry in
                legendRow(entry)
            }
        }
    }

    private func legendRow(_ entry: (year: Int, color: Color, totalMinutes: Double)) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(entry.color)
                .frame(width: 10, height: 10)

            Text(String(entry.year))
                .font(.caption)
                .foregroundStyle(.secondary)
                .strikethrough(hiddenYears.contains(entry.year))

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 0) {
                Text(formattedDuration(entry.totalMinutes))
                    .font(.caption)
                    .fontWeight(.semibold)

                if let delta = deltaLabel(for: entry.year, totalMinutes: entry.totalMinutes) {
                    Text(delta)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .opacity(hiddenYears.contains(entry.year) ? 0.35 : 1)
        .contentShape(Rectangle())
        .onTapGesture {
            toggleLegendEntry(for: entry.year)
        }
    }

    @ViewBuilder
    private func gameplayChart(in geometryProxy: GeometryProxy) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            scrollableGameplayChart(in: geometryProxy)
        } else {
            staticGameplayChart
        }
    }

    private var chartMarks: some View {
        Chart(visiblePoints) { point in
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
                    if let raw = value.as(Double.self) {
                        Text("\(formattedMinutes(raw)) min")
                    }
                }
            }
        }
        .chartLegend(.hidden)
    }

    private func scaledChart(domain: ClosedRange<Double>) -> some View {
        chartMarks.chartYScale(domain: domain)
    }

    private var staticGameplayChart: some View {
        scaledChart(domain: paddedDomain(for: visiblePoints))
            .overlay(alignment: .topLeading) {
                selectedPointHint
            }
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    private func scrollableGameplayChart(in geometryProxy: GeometryProxy) -> some View {
        // O domínio do eixo Y fica num @State separado (scrollableYDomain), recalculado com
        // debounce em vez de a cada frame do scroll/pinch — recalcular (e o relayout que o
        // Swift Charts faz) a cada frame é o que deixava o gesto lento.
        scaledChart(domain: scrollableYDomain)
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: visibleDomainLength)
            .chartScrollPosition(x: $scrollPosition)
            .scrollIndicators(.hidden)
            .chartBackground { proxy in
                Color.clear
                    .allowsHitTesting(false)
                    .onAppear { chartProxy = proxy }
                    .onChangeCompat(of: scrollPosition) { _ in chartProxy = proxy }
                    .onChangeCompat(of: visibleDomainLength) { _ in chartProxy = proxy }
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
                        persistence.persist(
                            visibleDomainLength,
                            key: .annualChartVisibleDomainLength,
                            storageType: .userDefaults
                        )
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
                selectedPointHint
            }
            .task(id: domainRecalcKey) {
                try? await Task.sleep(nanoseconds: 180_000_000)

                guard !Task.isCancelled else {
                    return
                }

                scrollableYDomain = paddedDomain(for: windowedPoints)
            }
            .onAppear {
                visibleDomainLength = loadedVisibleDomainLength
                scrollPosition = initialScrollPosition
                scrollableYDomain = paddedDomain(for: windowedPoints)
            }
            .onChangeCompat(of: maxVisibleDay) { _ in
                scrollPosition = initialScrollPosition
                scrollableYDomain = paddedDomain(for: windowedPoints)
            }
    }

    @ViewBuilder
    private var selectedPointHint: some View {
        if let selectedPoint {
            AnnualGameplayChartHintView(
                title: "Dia \(selectedPoint.dayLabel) - \(selectedPoint.yearLabel)",
                value: selectedPoint.value
            )
            .padding(8)
        }
    }

    // MARK: Private

    private static let defaultVisibleDomainLength = 15
    private static let minVisibleDomainLength = 5

    /// Todos os pontos de todos os anos, independente de estarem ocultos ou não.
    /// Usado para o eixo X e limites de navegação, que não devem mudar ao ocultar um ano.
    private var allPoints: [AnnualGameplayProgressPoint] {
        series
            .sorted(by: { $0.year < $1.year })
            .flatMap { $0.points }
    }

    /// Pontos realmente desenhados no gráfico — respeita os anos ocultados pela legenda.
    private var visiblePoints: [AnnualGameplayProgressPoint] {
        allPoints.filter { !hiddenYears.contains($0.year) }
    }

    private var legendEntries: [(year: Int, color: Color, totalMinutes: Double)] {
        series
            .sorted(by: { $0.year < $1.year })
            .map { (year: $0.year, color: paletteColor(for: $0.year), totalMinutes: $0.totalMinutes) }
    }

    private func toggleLegendEntry(for year: Int) {
        if hiddenYears.contains(year) {
            hiddenYears.remove(year)
        } else {
            hiddenYears.insert(year)
        }

        persistence.persist(hiddenYears, key: .annualChartHiddenYears, storageType: .userDefaults)
    }

    private func totalMinutes(forYear year: Int) -> Double? {
        series.first(where: { $0.year == year })?.totalMinutes
    }

    private func paddedDomain(for points: [AnnualGameplayProgressPoint]) -> ClosedRange<Double> {
        let values = points.map(\.value)

        guard let minValue = values.min(), let maxValue = values.max() else {
            return 0 ... 100
        }

        let range = max(maxValue - minValue, 0)
        let padding = max(range * 0.12, maxValue * 0.03, 1)
        let lowerBound = max(0, minValue - padding)
        let upperBound = maxValue + padding

        return lowerBound ... max(upperBound, lowerBound + 1)
    }

    /// Janela de dias atualmente visível na tela (considera o scroll horizontal e o zoom).
    private var visibleDayWindow: ClosedRange<Int> {
        let lower = max(1, min(scrollPosition, maxVisibleDay))
        let upper = min(maxVisibleDay, max(lower, scrollPosition + visibleDomainLength - 1))
        return lower ... upper
    }

    /// Pontos dentro da janela visível — usados só para calcular a escala do eixo Y,
    /// pra não desperdiçar espaço vertical com o range do ano inteiro quando o usuário
    /// deu scroll/zoom pra um trecho onde os valores acumulados ainda são baixos.
    private var windowedPoints: [AnnualGameplayProgressPoint] {
        visiblePoints.filter { visibleDayWindow.contains($0.day) }
    }

    /// Chave que resume tudo que afeta o domínio do eixo Y da variante com scroll — usada
    /// só pra disparar o recálculo com debounce (ver scrollableGameplayChart).
    private var domainRecalcKey: String {
        "\(scrollPosition)|\(visibleDomainLength)|\(hiddenYears.sorted())"
    }

    private func dayAxisLabel(forDay day: Int) -> String? {
        if let referenceDate = allPoints.first(where: { $0.day == day })?.referenceDate {
            return referenceDate.toFormattedString(dateFormat: "dd/MM")
        }

        guard let anchor = allPoints.first,
              let date = Calendar.current.date(
                  byAdding: .day,
                  value: day - anchor.day,
                  to: anchor.referenceDate
              ) else {
            return nil
        }

        return date.toFormattedString(dateFormat: "dd/MM")
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
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

        let candidates = visiblePoints.filter { $0.day == day }

        selectedPoint = candidates.min(by: {
            abs($0.value - yValue) < abs($1.value - yValue)
        })
    }

    private var maxVisibleDay: Int {
        allPoints.map(\.day).max() ?? 1
    }

    private var initialScrollPosition: Int {
        max(1, maxVisibleDay - (visibleDomainLength - 1))
    }

    private func clampedVisibleDomainLength(_ length: Int) -> Int {
        let upperBound = max(Self.minVisibleDomainLength, maxVisibleDay)
        return min(max(length, Self.minVisibleDomainLength), upperBound)
    }

    /// Nível de zoom (dias visíveis) salvo pelo usuário na última vez que deu pinch no gráfico.
    private var loadedVisibleDomainLength: Int {
        let saved: Int? = persistence.retrieve(.annualChartVisibleDomainLength, storageType: .userDefaults)

        guard let saved else {
            return Self.defaultVisibleDomainLength
        }

        return clampedVisibleDomainLength(saved)
    }

    /// Restaura os anos ocultos salvos — chamado uma vez quando o card aparece. O zoom é
    /// restaurado à parte, só na variante com scroll (iOS 17+), em loadedVisibleDomainLength.
    /// A posição horizontal sempre volta pro dia atual (não é lembrada).
    private func restorePersistedPreferences() {
        if let savedHiddenYears: Set<Int> = persistence.retrieve(.annualChartHiddenYears, storageType: .userDefaults) {
            hiddenYears = savedHiddenYears
        }
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
        let years = Set(visiblePoints.map(\.year)).sorted()

        return years.map { year in
            (String(year), paletteColor(for: year))
        }
    }

    private func paletteColor(for year: Int) -> Color {
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

    /// Ano atual — a base de comparação pra saber se os outros anos estão à frente ou atrás.
    private var baselineYear: Int {
        series.map(\.year).max() ?? 0
    }

    private var baselineTotalMinutes: Double? {
        totalMinutes(forYear: baselineYear)
    }

    /// "+1h3m" quando esse ano está atrás do ano atual (jogou menos até o mesmo dia do ano),
    /// "-2h35m" quando está à frente. Não mostra nada pro próprio ano atual.
    private func deltaLabel(for year: Int, totalMinutes: Double) -> String? {
        guard year != baselineYear, let baseline = baselineTotalMinutes else {
            return nil
        }

        return formattedSignedDuration(totalMinutes - baseline)
    }

    private func formattedSignedDuration(_ minutes: Double) -> String {
        let rounded = Int(minutes.rounded())

        if rounded == 0 {
            return "0m"
        }

        let sign = rounded > 0 ? "+" : "-"
        let absMinutes = abs(rounded)
        let hours = absMinutes / 60
        let remainingMinutes = absMinutes % 60

        if hours > 0 {
            return "\(sign)\(hours)h\(remainingMinutes)m"
        }

        return "\(sign)\(remainingMinutes)m"
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
