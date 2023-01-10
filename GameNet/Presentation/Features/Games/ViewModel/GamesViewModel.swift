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

class GamesViewModel: ObservableObject {

    // MARK: Lifecycle

    init() {
        cancellable = publisher
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Received finished")
                case let .failure(error):
                    switch error {
                    case let .server(message):
                        self.uiState = .error(message)
                    }
                }
            } receiveValue: { [weak self] pagedList in
                self?.pagedList = pagedList

                if let pagedList = pagedList {
                    self?.data += pagedList.result
                }

                self?.uiState = .success
            }
    }

    deinit {
        cancellable?.cancel()
    }

    // MARK: Public

    public let publisher = PassthroughSubject<PagedList<Game>?, APIError>()

    // MARK: Internal

    @Published var pagedList: PagedList<Game>? = nil
    @Published var data: [Game] = []
    @Published var searchedGames: [Game] = []
    @Published var uiState: GamesUIState = .idle

    func fetchData(search: String? = "", page: Int = 0) async {
        uiState = .loading

        let result = await repository.fetchData(search: search, page: page, pageSize: GameNetApp.pageSize)

        if let result = result {
            publisher.send(result)
        } else {
            publisher.send(completion: .failure(.server("Erro no carregamento de dados do servidor")))
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
    private var cancellable: AnyCancellable?
}

// extension PlatformsViewModel {
//    func editPlatformView(navigationPath: Binding<NavigationPath>, platformId: String? = nil) -> some View {
//        let platform = platforms?.first(where: { $0.id == platformId })
//
//        return PlatformRouter.makeEditPlatformView(navigationPath: navigationPath, platform: platform)
//    }
// }
