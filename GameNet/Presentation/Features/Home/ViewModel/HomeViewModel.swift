//
//  HomeViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 30/07/22.
//

import Foundation
import Combine
import SwiftData
import GameNet_Network
import Factory

class HomeViewModel: ObservableObject {
    @Published private var networkConnectivity = NetworkConnectivity()
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        networkConnectivity.$status
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                switch status {
                case .connected:
                    Task {
                        await self?.syncData()
                    }
                default:
                    break
                }
            }.store(in: &cancellable)
    }
    
    private var cancellable = Set<AnyCancellable>()
    
    private func syncData() async {
        let unsyncedPlatforms = fetchUnsyncedChanges(modelType: Platform.self)
        
        for platform in unsyncedPlatforms {
            platform.synced = true
            await repository.savePlatform(id: platform.id, platform: Platform(id: platform.id, name: platform.name))
        }
    }
    
    private func fetchUnsyncedChanges<T>(modelType: T.Type) -> [T] where T: Syncable, T: PersistentModel {
        do {
            let descriptor = FetchDescriptor<T>(predicate: #Predicate { entity in
                entity.synced == false
            })
            
            let result = try modelContext.fetch(descriptor)
            
            return result
        } catch {
            print("Não foi possível retornar itens")
        }
        
        return []
    }
    
    @Injected(RepositoryContainer.platformRepository) private var repository
}
