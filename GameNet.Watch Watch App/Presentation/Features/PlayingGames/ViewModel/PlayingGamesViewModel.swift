//
//  PlayingGamesViewModel.swift
//  GameNet.Watch Watch App
//
//  Created by Alliston Aleixo on 06/01/23.
//

import Combine
import Foundation

enum PlayingGamesUIState: Equatable {
    case loading
    case notLogged
    case empty
    case content
    case error(String)
}

@MainActor
final class PlayingGamesViewModel: ObservableObject {
    @Published var games: [WatchPlayingGame] = []
    @Published var uiState: PlayingGamesUIState = .loading
    @Published var selectedGameIndex: Int = 0
    @Published var selectedHabitDayISO: String = WatchConnectivityDateCodec.habitDayOptions().first ?? ""
    @Published var isSaving = false

    let habitDayOptions: [String] = WatchConnectivityDateCodec.habitDayOptions()

    private let service = WatchPlayingGamesService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        WatchConnectivityManager.shared.$context
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.applyCachedGamesIfNeeded()
            }
            .store(in: &cancellables)

        WatchConnectivityManager.shared.$cachedPayload
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.applyCachedGamesIfNeeded()
            }
            .store(in: &cancellables)

        WatchConnectivityManager.shared.$cachedAuthStatus
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                guard let self, let status else { return }
                if status == .notLogged, games.isEmpty {
                    uiState = .notLogged
                }
            }
            .store(in: &cancellables)
    }

    var selectedGame: WatchPlayingGame? {
        guard games.indices.contains(selectedGameIndex) else { return nil }
        return games[selectedGameIndex]
    }

    func load() async {
        WatchConnectivityManager.shared.refreshCachedPayload()
        applyCachedGamesIfNeeded()

        if uiState == .content || uiState == .empty || uiState == .notLogged {
            await refreshFromPhone()
            return
        }

        uiState = .loading
        await refreshFromPhone()
    }

    func toggleGameplay() async {
        guard let game = selectedGame, !isSaving else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            let updated = try await service.toggleGameplay(
                game: game,
                habitDayISO: selectedHabitDayISO
            )
            replaceGame(updated)
        } catch WatchPlayingGamesServiceError.notLogged {
            uiState = .notLogged
        } catch {
            if games.isEmpty {
                uiState = .error(error.localizedDescription)
            }
        }
    }

    // MARK: Private

    private func refreshFromPhone() async {
        do {
            try await service.checkAuth()
            let fetched = try await service.fetchPlayingGames(forceRefresh: uiState == .loading)
            games = fetched
            uiState = fetched.isEmpty ? .empty : .content
        } catch WatchPlayingGamesServiceError.notLogged {
            games = []
            uiState = .notLogged
        } catch {
            if games.isEmpty {
                uiState = .error(error.localizedDescription)
            }
        }
    }

    private func replaceGame(_ updated: WatchPlayingGame) {
        guard let index = games.firstIndex(where: { $0.id == updated.id }) else { return }
        games[index] = updated
    }

    private func applyCachedGamesIfNeeded() {
        guard let cached = WatchConnectivityManager.shared.playingGamesFromContext()?.games else {
            return
        }

        if WatchConnectivityManager.shared.cachedAuthStatus == .notLogged {
            games = []
            uiState = .notLogged
            return
        }

        games = cached
        uiState = cached.isEmpty ? .empty : .content
    }
}
