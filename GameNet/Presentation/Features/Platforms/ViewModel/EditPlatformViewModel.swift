//
//  EditPlatformViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 24/08/22.
//

import Combine
import Factory
import Foundation
import GameNet_Network
import SwiftUI

// MARK: - EditPlatformViewModel

class EditPlatformViewModel: ObservableObject {

    // MARK: Lifecycle

    init(platform: Platform) {
        self.platform = platform

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
            } receiveValue: { [weak self] platform in
                if let platform {
                    self?.platform = platform
                }

                self?.uiState = .success
            }
    }

    deinit {
        cancellable?.cancel()
    }

    // MARK: Public

    public let publisher = PassthroughSubject<Platform?, APIError>()

    // MARK: Internal

    @Published var platform: Platform
    @Published var uiState: EditPlatformUIState = .idle

    func save() async {
        uiState = .loading

        let result = await repository.savePlatform(id: platform.id, platform: Platform(id: platform.id, name: platform.name))

        if let result = result {
            publisher.send(result)
        } else {
            publisher.send(completion: .failure(.server("")))
        }
    }

    // MARK: Private

    @Injected(RepositoryContainer.platformRepository) private var repository
    private var cancellable: AnyCancellable?
}

extension EditPlatformViewModel {
    func goBackToPlatforms(navigationPath: Binding<NavigationPath>) {
        PlatformRouter.goBackToPlatforms(navigationPath: navigationPath)
    }
}
