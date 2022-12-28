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
import SwiftUI

// MARK: - PlatformsViewModel

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
                        self.state = .error(message)
                    }
                }
            } receiveValue: { [weak self] platforms in
                self?.platforms = platforms

                self?.state = .success
            }
    }

    deinit {
        cancellable?.cancel()
    }

    // MARK: Public

    public let publisher = PassthroughSubject<[Platform]?, APIError>()

    // MARK: Internal

    @Published var platforms: [Platform]? = nil
    @Published var state: PlatformsUIState = .idle

    func fetchData() async {
        state = .loading

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

extension PlatformsViewModel {
    func editPlatformView(navigationPath: Binding<NavigationPath>, platformId: String? = nil) -> some View {
        let platform = platforms?.first(where: { $0.id == platformId })

        return PlatformRouter.makeEditPlatformView(navigationPath: navigationPath, platform: platform)
    }
}
