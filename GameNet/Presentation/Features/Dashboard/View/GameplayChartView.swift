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
    let barWidth: CGFloat = 70

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Picker("Period", selection: $selectedPeriod) {
                ForEach(GameplayChartPeriod.allCases) { period in
                    Text(period.shortLabel).tag(period)
                }
            }
            .pickerStyle(.segmented)

            Text(caption)
                .font(.caption)
                .foregroundStyle(.secondary)

            GeometryReader { geometry in
                let chartWidth = max(
                    geometry.size.width,
                    CGFloat(bars.count) * barWidth
                )

                ScrollViewReader { scrollPosition in
                    ScrollView(.horizontal) {
                        Chart {
                            ForEach(bars) { bar in
                                BarMark(
                                    x: .value("Período", bar.label),
                                    y: .value(unitName, value(for: bar))
                                )
                            }
                        }
                        .chartXScale(domain: bars.map(\.label))
                        .foregroundColor(.main)
                        .frame(width: chartWidth)
                        .padding()
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
            .frame(height: 220)
        }
    }

    // MARK: Private

    private static let chartScrollId = 10001

    @State private var selectedPeriod: GameplayChartPeriod = .day

    private var bars: [GameplayChartBar] {
        Self.makeBars(from: data, period: selectedPeriod)
    }

    private var unitName: String {
        selectedPeriod.usesHours ? "Horas" : "Minutos"
    }

    private var caption: String {
        let total = bars.reduce(0) { $0 + $1.minutes }
        let totalText = "Total: \(Self.formattedDuration(minutes: total))"

        guard selectedPeriod != .year, !bars.isEmpty else {
            return "\(unitName) por \(selectedPeriod.name) · \(totalText)"
        }

        let average = total / Double(bars.count)
        return "\(unitName) por \(selectedPeriod.name) · \(totalText) · Média: \(Self.formattedDuration(minutes: average))"
    }

    private func value(for bar: GameplayChartBar) -> Double {
        selectedPeriod.usesHours ? bar.minutes / 60 : bar.minutes
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
                GameplayChartBar(startDate: $0.sortDate, label: $0.type, minutes: $0.count)
            }
        }

        let grouped = Dictionary(grouping: days) { day in
            bucketStart(for: day.sortDate, period: period, calendar: calendar)
        }

        let firstDate = days.first?.sortDate

        return grouped
            .map { start, shapes in
                let labelDate = max(start, firstDate ?? start)

                return GameplayChartBar(
                    startDate: start,
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
