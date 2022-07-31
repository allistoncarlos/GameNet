//
//  LoginViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 30/07/22.
//

import Combine
import GameNet_Keychain
import GameNet_Network
import SwiftUI

// MARK: - LoginError

enum LoginError: Error {
    case invalidUsernameOrPassword(String)
}

// MARK: - LoginViewModel

class LoginViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        cancellable = publisher.sink { completion in
            switch completion {
            case .finished:
                print("Received finished")
            case let .failure(error):
                switch error {
                case let .invalidUsernameOrPassword(message):
                    self.uiState = .error(message)
                }
            }
        } receiveValue: { loginResponse in
            self.saveToken(response: loginResponse)

            self.uiState = .success
        }
    }

    deinit {
        cancellable?.cancel()
    }

    // MARK: Internal

    @Published var uiState: LoginUIState = .idle

    func login(username: String, password: String) async {
        uiState = .loading

        let response = await NetworkManager.shared
            .performRequest(
                responseType: LoginResponse.self,
                endpoint: .login(data: LoginRequest(username: username, password: password))
            )

        if let response = response {
            publisher.send(response)
        } else {
            publisher.send(completion: .failure(.invalidUsernameOrPassword("Usuário ou senha inválidos")))
        }
    }

    // MARK: Private

    private var cancellable: AnyCancellable?

    private let publisher = PassthroughSubject<LoginResponse?, LoginError>()

    private func saveToken(response: LoginResponse?) {
        if let session = response {
            let dateFormatter = ISO8601DateFormatter()

            KeychainDataSource.id.set(session.id)
            KeychainDataSource.accessToken.set(session.accessToken)
            KeychainDataSource.refreshToken.set(session.refreshToken)
            KeychainDataSource.expiresIn.set(dateFormatter.string(from: session.expiresIn))
        } else {
            KeychainDataSource.clear()
        }
    }
}

extension LoginViewModel {
    func homeView() -> some View {
        return LoginRouter.makeHomeView()
    }
}
