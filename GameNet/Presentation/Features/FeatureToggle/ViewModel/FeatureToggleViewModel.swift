//
//  FeatureToggleViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 13/11/24.
//

import Foundation
import Combine

@MainActor
class FeatureToggleViewModel: ObservableObject {

    // MARK: Lifecycle

    init() {
        $state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
//                case let .success:
//                    self?.platforms = platforms
                default:
                    break
                }
            }.store(in: &cancellable)
    }

    @Published var state: FeatureToggleState = .idle
    var featureToggles: [RemoteConfigParameters] = RemoteConfigParameters.allCases

//    func fetchData() async {
//        state = .loading
//
//        let result = await repository.fetchData()
//
//        if let result {
//            state = .success(result)
//        } else {
//            state = .error("Erro no carregamento de dados do servidor")
//        }
//    }

    // MARK: Private
    private var cancellable = Set<AnyCancellable>()
}
