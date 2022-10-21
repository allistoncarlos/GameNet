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
            } receiveValue: { [weak self] games in
                self?.games = games

                self?.uiState = .success
            }
    }

    deinit {
        cancellable?.cancel()
    }

    // MARK: Public

    public let publisher = PassthroughSubject<PagedList<Game>?, APIError>()

    // MARK: Internal

    @Published var games: PagedList<Game>? = nil
    @Published var uiState: GamesUIState = .idle

    func fetchData() async {
        uiState = .loading

        let result = await repository.fetchData(search: "", page: 0, pageSize: 20)

        if let result = result {
            publisher.send(result)
        } else {
            publisher.send(completion: .failure(.server("Erro no carregamento de dados do servidor")))
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
