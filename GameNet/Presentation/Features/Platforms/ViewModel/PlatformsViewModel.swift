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

@MainActor
class PlatformsViewModel: ObservableObject {

    // MARK: Lifecycle

    init() {
        $state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
                case let .success(platforms):
                    self?.platforms = platforms
                default:
                    break
                }
            }.store(in: &cancellable)
    }

    // MARK: Internal

    @Published var platforms: [Platform]? = nil
    @Published var state: PlatformsState = .idle

    func fetchData(cache: Bool = true) async {
        state = .loading

        let result = await repository.fetchData(cache: cache)

        if let result {
            state = .success(result)
        } else {
            state = .error("Erro no carregamento de dados do servidor")
        }
    }

    // MARK: Private

    @Injected(RepositoryContainer.platformRepository) private var repository
    private var cancellable = Set<AnyCancellable>()
}

#if os(iOS)
extension PlatformsViewModel {
    func editPlatformView(navigationPath: Binding<NavigationPath>, platformId: String? = nil) -> some View {
        let platform = platforms?.first(where: { $0.id == platformId })

        return PlatformRouter.makeEditPlatformView(navigationPath: navigationPath, platform: platform)
    }
}
#endif
