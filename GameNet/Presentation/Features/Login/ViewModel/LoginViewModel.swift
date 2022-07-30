//
//  LoginViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 30/07/22.
//

import Combine
import SwiftUI

// MARK: - LoginViewModel

class LoginViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        cancellable = publisher.sink { value in
            if value {
                self.uiState = .success
//                self.uiState = .error("BLA")
            }
        }
    }

    deinit {
        cancellable?.cancel()
    }

    // MARK: Internal

    @Published var uiState: LoginUIState = .idle

    func login(email: String, password: String) {
        uiState = .loading

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.publisher.send(true)
        }
    }

    // MARK: Private

    private var cancellable: AnyCancellable?

    private let publisher = PassthroughSubject<Bool, Never>()
}

extension LoginViewModel {
    func homeView() -> some View {
        return LoginRouter.makeHomeView()
    }
}
