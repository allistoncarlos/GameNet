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
import SwiftData

// MARK: - PlatformsViewModel

@MainActor
class PlatformsViewModel: ObservableObject {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
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
    
    func fetchData(isConnected: Bool) async {
        if isConnected {
            await fetchRemoteData()
        } else {
            fetchLocalData()
        }
    }
    
    // MARK: Private
    @Injected(RepositoryContainer.platformRepository) private var repository
    private var cancellable = Set<AnyCancellable>()
    
    private func fetchRemoteData() async {
        state = .loading

        let result = await repository.fetchData()

        if let result {
            state = .success(result)
            
            self.syncData(result)
        } else {
            state = .error("Erro no carregamento de dados do servidor")
        }
    }
    
    private func fetchLocalData() {
        do {
            state = .loading
            
            let descriptor = FetchDescriptor<Platform>(
                sortBy: [SortDescriptor(\.name)]
            )

            let result = try modelContext.fetch(descriptor)
            
            state = .success(result)
        } catch {
            state = .error("Erro no carregamento de dados locais")
        }
    }
    
    private func syncData(_ platforms: [Platform]) {
        do {
            try modelContext.delete(model: Platform.self)
            
            platforms.forEach { platform in
                platform.synced = true
                modelContext.insert(platform)
            }
            
            try modelContext.save()
            
            self.fetchLocalData()
        } catch {
            print(error)
        }
    }
}

#if os(iOS)
extension PlatformsViewModel {
    func editPlatformView(
        navigationPath: Binding<NavigationPath>,
        platformId: String? = nil
    ) -> some View {
        let platform = platforms?.first(where: { $0.id == platformId })

        return PlatformRouter.makeEditPlatformView(
            modelContext: self.modelContext,
            navigationPath: navigationPath,
            platform: platform
        )
    }
}
#endif
