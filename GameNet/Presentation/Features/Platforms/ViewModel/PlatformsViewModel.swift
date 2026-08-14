//
//  PlatformsViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/08/22.
//

import Combine
import Factory
import Foundation
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
                    self?.prefetchIllustrations(platforms)
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

    @Injected(\.platformRepository) private var repository
    private var cancellable = Set<AnyCancellable>()

    private func prefetchIllustrations(_ platforms: [Platform]) {
        let urls = platforms.compactMap { PlatformIllustration.urlString(for: $0.name) }
        CoverImageCache.prefetch(urls: urls)
    }
}

extension PlatformsViewModel {
    func createPlatformView(navigationPath: Binding<NavigationPath>) -> some View {
        PlatformRouter.makeCreatePlatformView(navigationPath: navigationPath)
    }

    func platformDetailView(navigationPath: Binding<NavigationPath>, platformId: String) -> some View {
        let platform = platforms?.first(where: { $0.id == platformId })
            ?? Platform(id: platformId, name: String())

        return PlatformRouter.makePlatformDetailView(navigationPath: navigationPath, platform: platform)
    }
}
