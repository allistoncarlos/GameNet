//
//  GameDetailView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 24/01/23.
//

import CachedAsyncImage
import Factory
import SwiftUI
import UniformTypeIdentifiers

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

private enum GameDetailGameplayAction: Identifiable {
    case begin(start: Date)
    case finish
    case drop

    var id: String {
        switch self {
        case let .begin(start):
            return "begin-\(start.timeIntervalSince1970)"
        case .finish:
            return "finish"
        case .drop:
            return "drop"
        }
    }
}

// MARK: - GameDetailView

struct GameDetailView: View {
    @StateObject var viewModel: GameDetailViewModel

    @Binding var navigationPath: NavigationPath

    @State var isCopied = false
    @State private var isSaving = false
    @State private var isSessionsExpanded = false
    @State private var coverAccentColor = Color.main
    @State var showingConfirmation = false
    @State var buttonImage = "play.fill"
    @State var confirmText = "iniciar"
    @State private var activeGameplayAction: GameDetailGameplayAction?
    @State private var macContextMenuSession: GameplaySession?

    var body: some View {
        ZStack {
            blurredCoverBackground

            ScrollView {
                VStack(spacing: 15) {
                    heroCoverSection

                    Text(displayName)
                        .font(.system(.title))
                        .bold()
                        .multilineTextAlignment(.center)

                    if !displayPlatform.isEmpty {
                        Text(displayPlatform)
                            .font(.system(.title2))
                            .bold()
                            .multilineTextAlignment(.center)
                    }

                    if viewModel.game != nil {
                        gameInfoBar
                            .transition(.opacity)
                    } else {
                        loadingDetailsPlaceholder
                    }

                    gameSessionsSection
                }
                .padding(10)
                .animation(.smooth, value: viewModel.game != nil)
            }
        }
        .overlay(
            GameNetProgressHUD($isCopied, config: GameNetHUDConfig(
                type: .success,
                title: "Copiado",
                shouldAutoHide: true,
                allowsTapToHide: true,
                autoHideInterval: 3.0
            ))
        )
        .overlay(
            GameNetProgressHUD($isSaving, config: GameNetApp.hudConfig)
        )
        .onChange(of: viewModel.isSaving) { _, isSaving in
            self.isSaving = isSaving
        }
        .onChange(of: viewModel.isStarted) { oldValue, newValue in
            self.buttonImage = newValue ? "stop.fill" : "play.fill"
            self.confirmText = newValue ? "finalizar" : "iniciar"
        }
        .task {
            async let gameData: Void = viewModel.fetchData()
            async let funRating: Void = viewModel.fetchFunRating()
            _ = await (gameData, funRating)
        }
        .task(id: displayCoverURL) {
            guard !displayCoverURL.isEmpty else { return }
            coverAccentColor = await CoverAccentColor.from(urlString: displayCoverURL)
        }
        .confirmationDialog(
            "",
            isPresented: Binding(
                get: { activeGameplayAction != nil },
                set: { isPresented in
                    if !isPresented { activeGameplayAction = nil }
                }
            ),
            presenting: activeGameplayAction
        ) { action in
            switch action {
            case let .begin(start):
                Button("Iniciar Gameplay") {
                    Task {
                        _ = await viewModel.beginGameplay(start: start)
                    }
                }
            case .finish:
                Button("Finalizar Gameplay") {
                    Task {
                        _ = await viewModel.finishGameplay()
                    }
                }
            case .drop:
                Button("Dropar Gameplay", role: .destructive) {
                    Task {
                        _ = await viewModel.dropUserGameplay()
                    }
                }
            }
        } message: { action in
            switch action {
            case .begin:
                Text("Deseja iniciar um gameplay para \(displayName)?")
            case .finish:
                Text("Deseja finalizar o gameplay ativo de \(displayName)?")
            case .drop:
                Text("Deseja dropar o gameplay ativo de \(displayName)?")
            }
        }
    }

    private var displayCoverURL: String {
        viewModel.game?.cover ?? viewModel.preview?.coverURL ?? ""
    }

    private var displayName: String {
        viewModel.game?.name ?? viewModel.preview?.name ?? ""
    }

    private var displayPlatform: String {
        viewModel.game?.platform ?? viewModel.preview?.platform ?? ""
    }

    private var blurredCoverBackground: some View {
        GeometryReader { geometry in
            CachedAsyncImage(url: URL(string: displayCoverURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .scaleEffect(1.04)
                        .blur(radius: 8)
                        .saturation(1.1)
                        .overlay {
                            Color.black.opacity(0.08)
                        }
                        .overlay {
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.black.opacity(0.18)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                default:
                    Color.black
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
        .ignoresSafeArea()
    }

    private var heroCoverSection: some View {
        ZStack(alignment: .bottomTrailing) {
            CachedAsyncImage(url: URL(string: displayCoverURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                default:
                    coverImageSkeleton
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(height: 250)
            .shadow(color: .black.opacity(0.35), radius: 16, y: 8)
            .onTapGesture(count: 2) {
                #if os(macOS)
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(
                    viewModel.game?.id ?? viewModel.preview?.name ?? "",
                    forType: .string
                )
                isCopied = true
                #elseif os(iOS)
                UIPasteboard.general.setValue(
                    viewModel.game?.id ?? viewModel.preview?.name ?? "",
                    forPasteboardType: UTType.plainText.identifier
                )
                isCopied = true
                #endif
            }

            if FirebaseRemoteConfig.toggleGameplaySession, viewModel.game != nil {
                Button {
                    showingConfirmation = true
                } label: {
                    Image(systemName: buttonImage)
                        .frame(width: 40, height: 40)
                }
                .offset(x: -5, y: -5)
                .buttonBorderShape(.circle)
                .gameNetGlassProminentButtonStyle(tint: coverAccentColor.opacity(0.5))
                .animation(.smooth, value: coverAccentColor)
                .confirmationDialog("", isPresented: $showingConfirmation) {
                    Button("Confirmar") {
                        Task {
                            await viewModel.save()
                        }
                    }
                } message: {
                    Text("Deseja \(confirmText) o jogo \(displayName)?")
                }
            }
        }
    }

    private var coverImageSkeleton: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.secondary.opacity(0.2))
            .aspectRatio(2 / 3, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .redacted(reason: .placeholder)
    }

    private var loadingDetailsPlaceholder: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.secondary.opacity(0.15))
                .frame(height: 16)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.secondary.opacity(0.15))
                .frame(height: 16)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.secondary.opacity(0.15))
                .frame(width: 180, height: 16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .redacted(reason: .placeholder)
    }

    private var gameInfoBar: some View {
        HStack(spacing: 0) {
            infoMetricColumn(
                icon: "tag.fill",
                value: displayPrice,
                label: "Preço"
            )
            .padding(.trailing, 8)

            sessionsSummaryDivider

            infoMetricColumn(
                icon: "calendar",
                value: displayPlayingSince,
                label: "Jogando Desde"
            )
            .padding(.horizontal, 8)

            sessionsSummaryDivider

            infoMetricColumn(
                icon: "star.fill",
                value: displayRating,
                label: "Avaliação"
            )
            .padding(.leading, 8)
        }
        .padding(12)
        .gameNetGlassEffect(in: .rect(cornerRadius: 14))
    }

    @ViewBuilder
    private var gameSessionsSection: some View {
        if let gameplays = viewModel.gameplays {
            VStack(alignment: .leading, spacing: 10) {
                Text("Sessões de Jogo")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)

                sessionsSummaryRow(totalGameplayTime: gameplays.totalGameplayTime)

                if !viewModel.sortedGameplaySessions.isEmpty {
                    sessionsHistoryExpander
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .gameNetGlassEffect(in: .rect(cornerRadius: 14))
            .transition(.opacity)
        } else if viewModel.isLoadingGameplays {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
        }
    }

    private func sessionsSummaryRow(totalGameplayTime: String) -> some View {
        HStack(spacing: 0) {
            sessionsSummaryColumn(
                icon: "gamecontroller.fill",
                value: sessionsCountText,
                detail: lastSessionDetailText
            )
            .padding(.trailing, 10)

            sessionsSummaryDivider

            sessionsSummaryColumn(
                icon: "clock.fill",
                value: totalGameplayTime,
                detail: "Tempo de jogo"
            )
            .padding(.horizontal, 10)

            if viewModel.hasActiveGameplay {
                sessionsSummaryDivider

                dropGameplaySummaryColumn
                    .padding(.leading, 10)
            }
        }
    }

    private var dropGameplaySummaryColumn: some View {
        Button {
            activeGameplayAction = .drop
        } label: {
            VStack(spacing: 4) {
                Image(systemName: "xmark.circle")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                Text("Dropar")
                    .font(.system(size: 13, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text("Gameplay")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var sessionsHistoryExpander: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.12))
                .frame(height: 1)
                .padding(.vertical, 8)

            Button {
                withAnimation(.smooth) {
                    isSessionsExpanded.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 11, weight: .semibold))

                    Text("Histórico de sessões")
                        .font(.system(size: 12, weight: .semibold))

                    Text("(\(viewModel.sessionCount))")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isSessionsExpanded ? 180 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isSessionsExpanded {
                VStack(spacing: 6) {
                    ForEach(Array(viewModel.sortedGameplaySessions.enumerated()), id: \.element) { index, session in
                        gameplaySessionRow(for: session, index: index + 1)
                    }
                }
                .padding(.top, 8)
            }
        }
    }

    private var sessionsSummaryDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.12))
            .frame(width: 1)
            .padding(.vertical, 2)
    }

    private var displayPrice: String {
        viewModel.game?.value.toCurrencyString() ?? "—"
    }

    private var displayPlayingSince: String {
        viewModel.playingSinceText ?? "—"
    }

    private var displayRating: String {
        guard let funRating = viewModel.funRating else { return "—" }

        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.numberStyle = .decimal

        let average = formatter.string(from: funRating.average as NSDecimalNumber) ?? "5,0"

        if funRating.isMock {
            return "\(average) [MOCK]"
        }

        return average
    }

    private var sessionsCountText: String {
        let count = viewModel.sessionCount
        let suffix = count == 1 ? "sessão" : "sessões"
        return "\(count) \(suffix)"
    }

    private var lastSessionDetailText: String {
        guard let relativeLabel = viewModel.lastSessionRelativeLabel else {
            return "Última sessão —"
        }

        return "Última sessão \(relativeLabel)"
    }

    private func infoMetricColumn(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity)
    }

    private func sessionsSummaryColumn(icon: String, value: String, detail: String) -> some View {
        infoMetricColumn(icon: icon, value: value, label: detail)
    }

    @ViewBuilder
    private func gameplaySessionRow(for session: GameplaySession, index: Int) -> some View {
        gameplaySessionRowContent(for: session, index: index)
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 10))
            .gameNetPointerContextMenu(
                isPresented: macContextMenuIsPresented(for: session),
                onPointerMenu: { macContextMenuSession = session },
                menu: { gameplaySessionContextMenu(for: session) }
            )
    }

    @ViewBuilder
    private func gameplaySessionRowContent(for session: GameplaySession, index: Int) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Text("\(index)")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .frame(width: 16, alignment: .trailing)

            VStack(alignment: .leading, spacing: 2) {
                if session.finish == nil {
                    HStack(spacing: 4) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                        Text("Em andamento")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(.green)

                    Text(session.start.toFormattedString(dateFormat: GameNetApp.dateTimeFormat))
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                } else if let finishSession = session.finish {
                    Text(session.start.toFormattedString(dateFormat: GameNetApp.dateTimeFormat))
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)

                    Text("até \(finishSession.toFormattedString(dateFormat: GameNetApp.dateTimeFormat))")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if session.finish != nil {
                Text(session.totalGameplayTime)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(.white.opacity(0.1), in: Capsule())
            }
        }
    }

    @ViewBuilder
    private func gameplaySessionContextMenu(for session: GameplaySession) -> some View {
        if !viewModel.hasActiveGameplay {
            Button {
                macContextMenuSession = nil
                activeGameplayAction = .begin(start: session.start)
            } label: {
                Label("Iniciar Gameplay", systemImage: "play.circle.fill")
            }
        }

        if viewModel.hasActiveGameplay {
            Button {
                macContextMenuSession = nil
                activeGameplayAction = .finish
            } label: {
                Label("Finalizar Gameplay", systemImage: "stop.circle.fill")
            }
        }
    }

    private func macContextMenuIsPresented(for session: GameplaySession) -> Binding<Bool> {
        Binding(
            get: { macContextMenuSession == session },
            set: { isPresented in
                if !isPresented {
                    macContextMenuSession = nil
                }
            }
        )
    }
}

// MARK: - Previews

#Preview("Dark Mode") {
    let _ = Container.shared.gameRepository.register(factory: { MockGameRepository() })
    let _ = Container.shared.funRepository.register(factory: { FunRepository() })

    GameDetailView(
        viewModel: GameDetailViewModel(gameId: "1"),
        navigationPath: .constant(NavigationPath())
    ).preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    let _ = Container.shared.gameRepository.register(factory: { MockGameRepository() })
    let _ = Container.shared.funRepository.register(factory: { FunRepository() })

    GameDetailView(
        viewModel: GameDetailViewModel(gameId: "1"),
        navigationPath: .constant(NavigationPath())
    ).preferredColorScheme(.light)
}
