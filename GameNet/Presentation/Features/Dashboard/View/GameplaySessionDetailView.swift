//
//  GameplaySessionDetailView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 27/02/23.
//

import CachedAsyncImage
import SwiftUI

// MARK: - GameplaySessionRow

/// Uma sessão de gameplay dentro do card do dia.
struct GameplaySessionRow: View {
    let session: GameplaySession

    var body: some View {
        HStack(spacing: 12) {
            cover

            VStack(alignment: .leading, spacing: 3) {
                Text(session.gameName)
                    .font(.custom("AvenirNext-DemiBold", size: 16))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if !session.platformName.isEmpty {
                    Text(session.platformName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Label(timeRange, systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            durationBadge

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    // MARK: Private

    private var isOngoing: Bool {
        session.finish == nil
    }

    private var cover: some View {
        CachedAsyncImage(url: URL(string: session.gameCover)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            RoundedRectangle(cornerRadius: 8)
                .fill(.secondary.opacity(0.15))
                .overlay {
                    Image(systemName: "gamecontroller.fill")
                        .foregroundStyle(.secondary)
                }
        }
        .frame(width: 48, height: 64)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .gameCoverTransitionSource(id: session.userGameId)
    }

    private var timeRange: String {
        let start = session.start.toFormattedString(dateFormat: GameNetApp.timeFormat)

        guard let finish = session.finish else {
            return "Desde \(start)"
        }

        return "\(start) – \(finish.toFormattedString(dateFormat: GameNetApp.timeFormat))"
    }

    @ViewBuilder
    private var durationBadge: some View {
        if let finish = session.finish {
            Text(GameplayChartView.formattedDuration(minutes: max(0, (finish - session.start) / 60)))
                .font(.custom("AvenirNext-DemiBold", size: 14))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color.main))
        } else {
            Label("Jogando", systemImage: "play.fill")
                .font(.custom("AvenirNext-DemiBold", size: 13))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color.green))
        }
    }
}

// MARK: - GameplaySessionDayCard

/// Card de um dia: cabeçalho com dia da semana, data e total do dia, e as sessões.
struct GameplaySessionDayCard: View {
    let day: GameplaySessionDay

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 14)
                .padding(.top, 14)
                .padding(.bottom, 6)

            ForEach(Array(day.sessions.enumerated()), id: \.offset) { index, session in
                if index > 0 {
                    Divider()
                        .padding(.leading, 14 + 48 + 12)
                }

                SwiftUI.NavigationLink(value: session) {
                    GameplaySessionRow(session: session)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .gameNetGlassEffect(.regular, in: .rect(cornerRadius: 20))
    }

    // MARK: Private

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 1) {
                Text(day.date.toFormattedString(dateFormat: "EEEE", locale: .ptBR).capitalizedFirstLetter)
                    .font(.custom("AvenirNext-DemiBold", size: 18))

                Text(day.date.toFormattedString(dateFormat: GameNetApp.dateFormat))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 1) {
                Label(GameplayChartView.formattedDuration(minutes: day.totalMinutes), systemImage: "clock.fill")
                    .font(.custom("AvenirNext-DemiBold", size: 15))
                    .foregroundStyle(Color.main)

                Text(day.sessions.count == 1 ? "1 sessão" : "\(day.sessions.count) sessões")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - GameplaySessionDetailView

struct GameplaySessionDetailView: View {

    // MARK: Lifecycle

    /// `@StateObject` + autoclosure: o view model (que agrupa o ano inteiro e monta
    /// os dados do gráfico) é criado uma vez só, e não a cada vez que o Dashboard
    /// re-renderiza e reavalia o `navigationDestination`.
    init(
        viewModel: @autoclosure @escaping () -> GameplaySessionDetailViewModel,
        navigationPath: Binding<NavigationPath>
    ) {
        _viewModel = StateObject(wrappedValue: viewModel())
        _navigationPath = navigationPath
    }

    // MARK: Internal

    @StateObject var viewModel: GameplaySessionDetailViewModel

    @Binding var navigationPath: NavigationPath

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                GameplayChartView(
                    data: $viewModel.chartGameplaySession,
                    recentRegister: $viewModel.recentRegister
                )

                if !viewModel.days.isEmpty {
                    sessionsHeader
                        .padding(.top, 12)
                }

                // Lazy: as capas (CachedAsyncImage) só carregam quando o dia aparece na tela.
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.days) { day in
                        GameplaySessionDayCard(day: day)
                    }
                }
            }
            .padding(10)
        }
        .navigationView(title: viewModel.title)
    }

    // MARK: Private

    private var sessionsHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Sessões")
                .font(.dashboardGameTitle)

            Spacer()

            Text("\(plural(viewModel.days.count, "dia", "dias")) · \(plural(sessionCount, "sessão", "sessões"))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 4)
    }

    private func plural(_ count: Int, _ singular: String, _ pluralForm: String) -> String {
        "\(count) \(count == 1 ? singular : pluralForm)"
    }

    private var sessionCount: Int {
        viewModel.days.reduce(0) { $0 + $1.sessions.count }
    }
}
