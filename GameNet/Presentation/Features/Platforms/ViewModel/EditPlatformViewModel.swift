//
//  EditPlatformViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 24/08/22.
//

import Foundation

import Combine
import Factory
import Foundation
import GameNet_Network

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
//                self?.platforms = platforms

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

    // MARK: Private

    @Injected(RepositoryContainer.platformRepository) private var repository
    private var cancellable: AnyCancellable?
}
