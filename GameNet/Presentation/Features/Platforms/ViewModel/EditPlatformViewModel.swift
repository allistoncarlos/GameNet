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

@MainActor
class EditPlatformViewModel: ObservableObject {

    // MARK: Lifecycle

    init(platform: Platform) {
        self.platform = platform

        $state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
                case let .success(platform):
                    self?.platform = platform
                default:
                    break
                }
            }.store(in: &cancellable)
    }


    // MARK: Internal

    @Published var platform: Platform
    @Published var state: EditPlatformState = .idle

    func save() async {
        state = .loading

        let result = await repository.savePlatform(id: platform.id, platform: Platform(id: platform.id, name: platform.name))

        if let result {
            state = .success(result)
        } else {
            state = .error("Erro no salvamento de dados do servidor")
        }
    }

    // MARK: Private

    @Injected(RepositoryContainer.platformRepository) private var repository
    private var cancellable = Set<AnyCancellable>()
}

extension EditPlatformViewModel {
    func goBackToPlatforms(navigationPath: Binding<NavigationPath>) {
        PlatformRouter.goBackToPlatforms(navigationPath: navigationPath)
    }
}
