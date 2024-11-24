//
//  ServerDrivenDashboardViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/11/24.
//

import Foundation
import GameNet_Network
import Factory
import Combine

@MainActor
class ServerDrivenDashboardViewModel: ObservableObject {
    @Published var state: ServerDrivenDashboardState = .idle
    @Published var serverDriven: ServerDriven? = nil
    @Published var dynamicContainer: DynamicContainer? = nil
    
    init() {
        $state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
                case let .success(serverDriven):
                    // TODO: Não tá chegando aqui
                    self?.serverDriven = serverDriven
                    self?.dynamicContainer = self?.decode(json: serverDriven.json)
                default:
                    break
                }
            }.store(in: &cancellable)
    }

    func fetchData() async {
        state = .loading

        let result = await repository.fetch(slug: "dashboard")

        if let result {
            state = .success(result)
        } else {
            state = .error("Erro no carregamento de dados do servidor")
        }
    }
    
    private func decode(json: String) -> DynamicContainer? {
        if let json = json.data(using: .utf8) {
            do {
                let decodedData = try JSONDecoder().decode(DynamicContainer.self, from: json)
                
                return decodedData
            } catch {
                print("Erro ao decodificar JSON: \(error)")
            }
        }
        
        return nil
    }
    
    @Injected(RepositoryContainer.serverDrivenRepository) private var repository
    private var cancellable = Set<AnyCancellable>()
}
