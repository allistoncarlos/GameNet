//
//  PlatformsViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/08/22.
//

import Combine
import Factory
import Foundation
import GameNet_Network

class PlatformsViewModel: ObservableObject {
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
            } receiveValue: { [weak self] platforms in
                self?.platforms = platforms

                self?.uiState = .success
            }
    }

    deinit {
        cancellable?.cancel()
    }

    // MARK: Public

    public let publisher = PassthroughSubject<[Platform]?, APIError>()

    // MARK: Internal

    @Published var platforms: [Platform]? = nil
    @Published var uiState: PlatformsUIState = .idle

    func fetchData() async {
        uiState = .loading

        let result = await repository.fetchData()

        if let result = result {
            publisher.send(result)
        } else {
            publisher.send(completion: .failure(.server("Erro no carregamento de dados do servidor")))
        }
    }

    // MARK: Private

    @Injected(RepositoryContainer.platformRepository) private var repository
    private var cancellable: AnyCancellable?
}