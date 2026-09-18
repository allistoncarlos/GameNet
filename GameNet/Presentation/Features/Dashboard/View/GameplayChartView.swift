//
//  GameplayChartView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 18/06/23.
//

import Charts
import SwiftUI

// MARK: - GameplayChartPeriod

/// Agrupamento das barras do gráfico de gameplay do ano: cada aba define o
/// tamanho do período que uma barra representa.
enum GameplayChartPeriod: Int, CaseIterable, Identifiable {
    case day
    case week
    case month
    case semester
    case year

    var id: Int { rawValue }

    var shortLabel: String {
        switch self {
        case .day: return "D"
        case .week: return "S"
        case .month: return "M"
        case .semester: return "6M"
        case .year: return "A"
        }
    }

    /// Nome do período no singular, usado na legenda ("Horas por semana").
    var name: String {
        switch self {
        case .day: return "dia"
        case .week: return "semana"
        case .month: return "mês"
        case .semester: return "semestre"
        case .year: return "ano"
        }
    }

    /// No dia a dia o volume é pequeno o bastante para ler em minutos; nos
    /// agrupamentos maiores o eixo fica mais legível em horas.
    var usesHours: Bool { self != .day }
}

// MARK: - GameplayChartBar

/// Uma barra já agregada para o período selecionado.
struct GameplayChartBar: Identifiable {
    let startDate: Date
    /// Primeiro e último dia com dados dentro do período (usados no detalhamento).
    let firstDay: Date
    let lastDay: Date
    let label: String
    /// Total de minutos jogados no período.
    let minutes: Double

    var id: Date { startDate }
}

// MARK: - GameplayChartView

struct GameplayChartView: View {

    // MARK: Internal

    @Binding var data: [BarShape]
    @Binding var recentRegister: UUID?
    let barWidth: CGFloat = 56

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            periodSelector

            selectionHeader

            if bars.isEmpty {
                emptyState
            } else {
                chart
            }

            statistics
        }
        .foregroundStyle(.white)
        .padding(16)
        .gameNetGlassEffect(
            .tinted(Color.secondaryCardBackground),
            in: .rect(cornerRadius: 20)
        )
        .onChangeCompat(of: selectedPeriod) { _ in
            selectedBarId = nil
        }
    }

    // MARK: Private

    private static let chartScrollId = 10001
    private static let chartHeight: CGFloat = 220

    @State private var selectedPeriod: GameplayChartPeriod = .day
    /// Barra tocada. Enquanto houver uma, o cabeçalho mostra o detalhamento dela.
    @State private var selectedBarId: Date?
    @Namespace private var periodSelection

    private var bars: [GameplayChartBar] {
        Self.makeBars(from: data, period: selectedPeriod)
    }

    private var selectedBar: GameplayChartBar? {
        guard let selectedBarId else { return nil }
        return bars.first(where: { $0.id == selectedBarId })
    }

    private var totalMinutes: Double {
        bars.reduce(0) { $0 + $1.minutes }
    }

    /// Média por barra do período escolhido. Na aba A (uma barra só) cai para a
    /// média por dia, que é o que ainda diz alguma coisa.
    private var average: (label: String, minutes: Double) {
        if selectedPeriod == .year {
            let days = max(data.count, 1)
            return ("Média por dia", totalMinutes / Double(days))
        }

        return ("Média por \(selectedPeriod.name)", totalMinutes / Double(max(bars.count, 1)))
    }

    /// Maior dia do ano, independente da aba — sempre olhando os dados diários.
    private var bestDay: BarShape? {
        Self.bestDay(in: data)
    }

    private var unitName: String {
        selectedPeriod.usesHours ? "Horas" : "Minutos"
    }

    // MARK: Period selector

    private var periodSelector: some View {
        HStack(spacing: 4) {
            ForEach(GameplayChartPeriod.allCases) { period in
                let isSelected = period == selectedPeriod

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selectedPeriod = period
                    }
                } label: {
                    Text(period.shortLabel)
                        .font(.custom("AvenirNext-DemiBold", size: 15))
                        .foregroundStyle(isSelected ? Color.secondaryCardBackground : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background {
                            if isSelected {
                                Capsule()
                                    .fill(.white)
                                    .matchedGeometryEffect(id: "period", in: periodSelection)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Por \(period.name)")
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(4)
        .background(Capsule().fill(.white.opacity(0.15)))
    }

    // MARK: Selection header

    /// Altura fixa para o gráfico não pular quando o detalhamento aparece/some.
    private var selectionHeader: some View {
        Group {
            if let selectedBar {
                detail(for: selectedBar)
            } else {
                Label("Toque em uma barra para ver o detalhamento", systemImage: "hand.tap")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.75))
            }
        }
        .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
    }

    private func detail(for bar: GameplayChartBar) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(Self.detailTitle(for: bar, period: selectedPeriod))
                    .font(.dashboardGameSubtitle)
                    .foregroundStyle(.white.opacity(0.85))

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(Self.formattedDuration(minutes: bar.minutes))
                        .font(.dashboardGameTitle)

                    if let share = shareOfTotal(for: bar) {
                        Text(share)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(.white.opacity(0.2)))
                    }
                }
            }

            Spacer(minLength: 0)

            Button {
                selectedBarId = nil
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.75))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Fechar detalhamento")
        }
    }

    /// "12% do total" — não faz sentido na aba A, que só tem uma barra.
    private func shareOfTotal(for bar: GameplayChartBar) -> String? {
        guard selectedPeriod != .year, totalMinutes > 0 else { return nil }
        let percent = Int((bar.minutes / totalMinutes * 100).rounded())
        return "\(percent)% do total"
    }

    // MARK: Chart

    private var chart: some View {
        GeometryReader { geometry in
            let chartWidth = max(
                geometry.size.width,
                CGFloat(bars.count) * barWidth
            )

            ScrollViewReader { scrollPosition in
                ScrollView(.horizontal) {
                    chartContent
                        .frame(width: chartWidth)
                        .padding(.top, 8)
                        .id(Self.chartScrollId)
                }
                .scrollIndicators(.hidden)
                .onAppear {
                    scrollPosition.scrollTo(Self.chartScrollId, anchor: .topTrailing)
                }
                .onChangeCompat(of: selectedPeriod) { _ in
                    // Ao trocar de aba, volta para o período mais recente.
                    scrollPosition.scrollTo(Self.chartScrollId, anchor: .topTrailing)
                }
            }
        }
        .frame(height: Self.chartHeight)
    }

    private var chartContent: some View {
        Chart {
            ForEach(bars) { bar in
                BarMark(
                    x: .value("Período", bar.label),
                    y: .value(unitName, value(forMinutes: bar.minutes)),
                    width: .ratio(0.6)
                )
                .cornerRadius(6)
                .foregroundStyle(barGradient(isSelected: bar.id == selectedBarId))
                .opacity(selectedBarId == nil || selectedBarId == bar.id ? 1 : 0.35)
                .annotation(position: .top, spacing: 4) {
                    if isBestDayBar(bar) {
                        Image(systemName: "trophy.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }
                }
            }

            if bars.count > 1, selectedPeriod != .year {
                RuleMark(y: .value("Média", value(forMinutes: average.minutes)))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(.white.opacity(0.7))
                    .annotation(position: .top, alignment: .trailing, spacing: 2) {
                        Text("média")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.8))
                    }
            }
        }
        .chartXScale(domain: bars.map(\.label))
        .chartYScale(domain: 0 ... yUpperBound)
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                    .foregroundStyle(.white.opacity(0.25))
                AxisValueLabel {
                    if let raw = value.as(Double.self) {
                        Text(axisLabel(for: raw))
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }
            }
        }
#if !os(tvOS)
        .chartOverlay { proxy in
            GeometryReader { overlayGeometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        selectBar(at: location, proxy: proxy, geometry: overlayGeometry)
                    }
            }
        }
#endif
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis")
                .font(.title2)
            Text("Nenhuma sessão registrada")
                .font(.dashboardGameSubtitle)
        }
        .foregroundStyle(.white.opacity(0.8))
        .frame(maxWidth: .infinity, minHeight: Self.chartHeight)
    }

    /// Folga no topo para o troféu e o rótulo da média não serem cortados.
    private var yUpperBound: Double {
        let maxValue = bars.map { value(forMinutes: $0.minutes) }.max() ?? 0
        return max(maxValue * 1.18, 1)
    }

    private func barGradient(isSelected: Bool) -> LinearGradient {
        LinearGradient(
            colors: [.white, .white.opacity(isSelected ? 0.9 : 0.55)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func isBestDayBar(_ bar: GameplayChartBar) -> Bool {
        guard selectedPeriod == .day, let bestDay else { return false }
        return bar.startDate == bestDay.sortDate
    }

    private func value(forMinutes minutes: Double) -> Double {
        selectedPeriod.usesHours ? minutes / 60 : minutes
    }

    private func axisLabel(for value: Double) -> String {
        let rounded = Int(value.rounded())
        return selectedPeriod.usesHours ? "\(rounded)h" : "\(rounded)m"
    }

#if !os(tvOS)
    /// Converte o toque na barra correspondente; tocar de novo na mesma (ou fora
    /// das barras) fecha o detalhamento.
    private func selectBar(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) {
        let plotOrigin = geometry[proxy.plotAreaFrame].origin
        let xPosition = location.x - plotOrigin.x

        guard let label: String = proxy.value(atX: xPosition),
              let bar = bars.first(where: { $0.label == label }),
              bar.id != selectedBarId else {
            withAnimation(.easeOut(duration: 0.2)) { selectedBarId = nil }
            return
        }

        withAnimation(.easeOut(duration: 0.2)) { selectedBarId = bar.id }
    }
#endif

    // MARK: Statistics

    private var statistics: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("\(unitName) por \(selectedPeriod.name)", systemImage: "chart.bar.fill")
                .font(.dashboardGameSubtitle)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(.white.opacity(0.18)))

            HStack(spacing: 12) {
                statTile(
                    icon: "sum",
                    title: "Total",
                    value: Self.formattedDuration(minutes: totalMinutes)
                )

                statTile(
                    icon: "divide",
                    title: average.label,
                    value: Self.formattedDuration(minutes: average.minutes)
                )
            }

            statTile(
                icon: "trophy.fill",
                title: "Maior dia",
                value: bestDay.map { Self.formattedDuration(minutes: $0.count) } ?? "—",
                subtitle: bestDay.map { Self.bestDayTitle(for: $0.sortDate) }
            )
        }
    }

    private func statTile(icon: String, title: String, value: String, subtitle: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.dashboardGameSubtitle)
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(value)
                .font(.dashboardGameTitle)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.15))
        )
    }
}

// MARK: - Aggregation

extension GameplayChartView {
    /// Soma as barras diárias (`BarShape`, em minutos) no período escolhido.
    /// Semanas, meses e semestres que começam antes do primeiro registro usam
    /// a data do primeiro registro no rótulo, para não mostrar o ano anterior.
    static func makeBars(
        from data: [BarShape],
        period: GameplayChartPeriod,
        calendar: Calendar = .current
    ) -> [GameplayChartBar] {
        let days = data.sorted(by: { $0.sortDate < $1.sortDate })

        guard period != .day else {
            return days.map {
                GameplayChartBar(
                    startDate: $0.sortDate,
                    firstDay: $0.sortDate,
                    lastDay: $0.sortDate,
                    label: $0.type,
                    minutes: $0.count
                )
            }
        }

        let grouped = Dictionary(grouping: days) { day in
            bucketStart(for: day.sortDate, period: period, calendar: calendar)
        }

        let firstDate = days.first?.sortDate

        return grouped
            .map { start, shapes in
                let labelDate = max(start, firstDate ?? start)

                let dates = shapes.map(\.sortDate)

                return GameplayChartBar(
                    startDate: start,
                    firstDay: dates.min() ?? start,
                    lastDay: dates.max() ?? start,
                    label: label(for: labelDate, period: period, calendar: calendar),
                    minutes: shapes.reduce(0) { $0 + $1.count }
                )
            }
            .sorted(by: { $0.startDate < $1.startDate })
    }

    private static func bucketStart(
        for date: Date,
        period: GameplayChartPeriod,
        calendar: Calendar
    ) -> Date {
        switch period {
        case .day:
            return calendar.startOfDay(for: date)
        case .week:
            return calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        case .month:
            return calendar.dateInterval(of: .month, for: date)?.start ?? date
        case .semester:
            let components = calendar.dateComponents([.year, .month], from: date)
            let month = (components.month ?? 1) <= 6 ? 1 : 7
            return calendar.date(from: DateComponents(year: components.year, month: month, day: 1)) ?? date
        case .year:
            return calendar.dateInterval(of: .year, for: date)?.start ?? date
        }
    }

    private static func label(
        for date: Date,
        period: GameplayChartPeriod,
        calendar: Calendar
    ) -> String {
        switch period {
        case .day, .week:
            return date.toFormattedString(dateFormat: GameNetApp.shortDateFormat)
        case .month:
            return date.toFormattedString(dateFormat: "MMM").capitalized
        case .semester:
            let month = calendar.component(.month, from: date)
            return month <= 6 ? "1º sem" : "2º sem"
        case .year:
            return String(calendar.component(.year, from: date))
        }
    }

    /// Título do detalhamento de uma barra, por extenso ("Semana de 05/01 a 11/01").
    static func detailTitle(
        for bar: GameplayChartBar,
        period: GameplayChartPeriod,
        calendar: Calendar = .current
    ) -> String {
        let year = calendar.component(.year, from: bar.firstDay)

        switch period {
        case .day:
            return bar.firstDay.toFormattedString(dateFormat: GameNetApp.dateFormat)
        case .week:
            let first = bar.firstDay.toFormattedString(dateFormat: GameNetApp.shortDateFormat)
            let last = bar.lastDay.toFormattedString(dateFormat: GameNetApp.shortDateFormat)
            return first == last ? "Semana de \(first)" : "Semana de \(first) a \(last)"
        case .month:
            let month = bar.firstDay.toFormattedString(dateFormat: "LLLL").capitalized
            return "\(month) de \(year)"
        case .semester:
            let semester = calendar.component(.month, from: bar.firstDay) <= 6 ? 1 : 2
            return "\(semester)º semestre de \(year)"
        case .year:
            return "Ano de \(year)"
        }
    }

    /// Dia com mais minutos jogados; `nil` se nenhum dia tiver sessão.
    static func bestDay(in data: [BarShape]) -> BarShape? {
        guard let best = data.max(by: { $0.count < $1.count }), best.count > 0 else {
            return nil
        }

        return best
    }

    /// "Sábado, 12/03/2026".
    static func bestDayTitle(for date: Date) -> String {
        let weekday = date.toFormattedString(dateFormat: "EEEE").capitalized
        return "\(weekday), \(date.toFormattedString(dateFormat: GameNetApp.dateFormat))"
    }

    static func formattedDuration(minutes: Double) -> String {
        let totalMinutes = Int(minutes.rounded())
        let hours = totalMinutes / 60
        let remainingMinutes = totalMinutes % 60

        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        }

        return "\(remainingMinutes)m"
    }
}
