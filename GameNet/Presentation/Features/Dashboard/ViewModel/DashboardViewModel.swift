//
//  DashboardViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 22/08/22.
//

import Combine
import Factory
import Foundation
import GameNet_Network

@MainActor
class DashboardViewModel: ObservableObject {

    // MARK: Lifecycle

    init() {
        $state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
                case let .success(dashboard):
                    self?.dashboard = dashboard
                default:
                    break
                }
            }.store(in: &cancellable)
    }

    // MARK: Internal

    @Published var dashboard: Dashboard? = nil
    @Published var state: DashboardState = .idle

    func fetchData() async {
        state = .loading

        let result = await repository.fetchData()

        if let result {
            state = .success(result)
        } else {
            state = .error("Erro no carregamento de dados do servidor")
        }
    }

    // MARK: Private

    @Injected(RepositoryContainer.dashboardRepository) private var repository
    private var cancellable = Set<AnyCancellable>()
}
