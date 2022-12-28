//
//  GamesViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 20/10/22.
//

import Combine
import Factory
import Foundation
import GameNet_Network
import SwiftUI

// MARK: - PlatformsViewModel

@MainActor
class GamesViewModel: ObservableObject {

    // MARK: Lifecycle

    init() {
        $state
            .receive(on: DispatchQueue.main)
            .sink { state in
                switch state {
                case let .error(errorMessage):
                    print("[ERROR]: \(errorMessage)")
                default:
                    break
                }
            }.store(in: &cancellable)
    }

    // MARK: Public

    public let publisher = PassthroughSubject<PagedList<Game>?, APIError>()

    // MARK: Internal

    @Published var pagedList: PagedList<Game>? = nil
    @Published var data: [Game] = []
    @Published var searchedGames: [Game] = []
    @Published var state: GamesUIState = .idle

    func fetchData(search: String? = "", page: Int = 0) async {
        state = .loading

        let pagedList = await repository.fetchData(search: search, page: page, pageSize: GameNetApp.pageSize)

        if let pagedList {
            self.pagedList = pagedList
            data += pagedList.result

            state = .success
        } else {
            state = .error("Erro no carregamento de dados do servidor")
        }
    }

    func loadNextPage(currentGame: Game) async {
        let thresholdIndex = data.index(data.endIndex, offsetBy: -5)

        if data.firstIndex(where: { $0.id == currentGame.id }) == thresholdIndex {
            let page = pagedList?.page ?? 0
            await fetchData(search: pagedList?.search, page: page + 1)
        }
    }

    // MARK: Private

    @Injected(RepositoryContainer.gameRepository) private var repository
    private var cancellable = Set<AnyCancellable>()
}

// extension PlatformsViewModel {
//    func editPlatformView(navigationPath: Binding<NavigationPath>, platformId: String? = nil) -> some View {
//        let platform = platforms?.first(where: { $0.id == platformId })
//
//        return PlatformRouter.makeEditPlatformView(navigationPath: navigationPath, platform: platform)
//    }
// }
