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
import SwiftData

// MARK: - EditPlatformViewModel

@MainActor
class EditPlatformViewModel: ObservableObject {
    private var modelContext: ModelContext

    init(platform: Platform, modelContext: ModelContext) {
        self.platform = platform
        self.modelContext = modelContext

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

    func save(isConnected: Bool) async {
        if (isConnected) {
            await self.saveRemote()
        } else {
            self.saveLocal()
        }
    }

    // MARK: Private

    @Injected(RepositoryContainer.platformRepository) private var repository
    private var cancellable = Set<AnyCancellable>()
    
    private func saveRemote() async {
        state = .loading

        let result = await repository.savePlatform(id: platform.id, platform: Platform(id: platform.id, name: platform.name))

        if let result {
            state = .success(result)
        } else {
            state = .error("Erro no salvamento de dados do servidor")
        }
    }
    
    private func saveLocal() {
        state = .loading
        
        do {
            var descriptor: FetchDescriptor<Platform>?
            
            if let id = self.platform.id {
                // TODO: UPDATE HERE
//                try modelContext.save()

                descriptor = FetchDescriptor<Platform>(predicate: #Predicate { platform in
                    platform.id == id
                })
            } else {
                modelContext.insert(self.platform)
                try modelContext.save()

                let name = self.platform.name
                
                descriptor = FetchDescriptor<Platform>(predicate: #Predicate { platform in
                    platform.name == name
                })
            }

            descriptor?.fetchLimit = 1
            
            if let descriptor {
                let result = try modelContext.fetch(descriptor)
                
                if result.count == 1 {
                    state = .success(self.platform)
                } else {
                    state = .error("Erro no salvamento de dados local")
                }
            }
        } catch {
            state = .error("Erro no salvamento de dados local")
        }
    }
}

#if os(iOS)
extension EditPlatformViewModel {
    func goBackToPlatforms(navigationPath: Binding<NavigationPath>) {
        PlatformRouter.goBackToPlatforms(navigationPath: navigationPath)
    }
}
#endif
