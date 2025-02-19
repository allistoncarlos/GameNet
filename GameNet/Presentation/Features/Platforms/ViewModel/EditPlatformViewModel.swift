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
            if let id = platform.id {
                try update(id: id)
            } else {
                try insert()
            }
        } catch {
            state = .error("Erro no salvamento de dados local")
        }
    }
    
    private func update(id: String) throws {
        let descriptor = createUpdateDescriptor(for: id)
        
        let result = try modelContext.fetch(descriptor)
        
        if result.count == 1, let platformResult = result.first {
            platformResult.synced = false
            try modelContext.save()
            state = .success(platform)
        } else {
            state = .error("Erro ao atualizar plataforma local")
        }
    }
    
    private func insert() throws {
        modelContext.insert(platform)
        try modelContext.save()
            
        let descriptor = createInsertDescriptor(for: platform.name)

        let result = try modelContext.fetch(descriptor)
        
        if result.count == 1 {
            state = .success(platform)
        } else {
            state = .error("Erro ao inserir plataforma local")
        }
    }
    
    private func createUpdateDescriptor(for id: String) -> FetchDescriptor<Platform> {
        var descriptor = FetchDescriptor<Platform>(predicate: #Predicate { platform in
            platform.id == id
        })
        
        descriptor.fetchLimit = 1
        
        return descriptor
    }

    private func createInsertDescriptor(for name: String) -> FetchDescriptor<Platform> {
        var descriptor = FetchDescriptor<Platform>(predicate: #Predicate { platform in
            platform.name == name
        })
        
        descriptor.fetchLimit = 1
        
        return descriptor
    }
}

#if os(iOS)
extension EditPlatformViewModel {
    func goBackToPlatforms(navigationPath: Binding<NavigationPath>) {
        PlatformRouter.goBackToPlatforms(navigationPath: navigationPath)
    }
}
#endif
