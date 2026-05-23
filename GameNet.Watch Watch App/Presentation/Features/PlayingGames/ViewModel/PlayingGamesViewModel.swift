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
    }

    var selectedGame: WatchPlayingGame? {
        guard games.indices.contains(selectedGameIndex) else { return nil }
        return games[selectedGameIndex]
    }

    func load() async {
        uiState = .loading

        do {
            _ = try await service.checkAuth()
            games = try await service.fetchPlayingGames()
            uiState = games.isEmpty ? .empty : .content
        } catch WatchPlayingGamesServiceError.notLogged {
            games = []
            uiState = .notLogged
        } catch {
            games = []
            uiState = .error(error.localizedDescription)
        }
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
        } catch {
            uiState = .error(error.localizedDescription)
        }
    }

    // MARK: Private

    private func replaceGame(_ updated: WatchPlayingGame) {
        guard let index = games.firstIndex(where: { $0.id == updated.id }) else { return }
        games[index] = updated
    }

    private func applyCachedGamesIfNeeded() {
        guard let cached = WatchConnectivityManager.shared.playingGamesFromContext()?.games,
              !cached.isEmpty else {
            return
        }

        games = cached
        if uiState == .loading {
            uiState = cached.isEmpty ? .empty : .content
        }
    }
}
