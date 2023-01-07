//
//  LoginViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 30/07/22.
//

import Combine
import Factory
import GameNet_Keychain
import SwiftUI

// MARK: - LoginError

enum LoginError: Error {
    case invalidUsernameOrPassword(String)
}

// MARK: - LoginViewModel

class LoginViewModel: ObservableObject {

    // MARK: Lifecycle

    init() {
        cancellable = publisher
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Received finished")
                case let .failure(error):
                    switch error {
                    case let .invalidUsernameOrPassword(message):
                        self.uiState = .error(message)
                    }
                }
            } receiveValue: { login in
                self.saveToken(response: login)

                self.uiState = .success
            }
    }

    deinit {
        cancellable?.cancel()
    }

    // MARK: Public

    public let publisher = PassthroughSubject<Login?, LoginError>()

    // MARK: Internal

    @Published var uiState: LoginUIState = .idle

    func login(username: String, password: String) async {
        uiState = .loading

        let result = await repository.login(login: Login(username: username, password: password))

        if let result = result {
            publisher.send(result)
        } else {
            publisher.send(completion: .failure(.invalidUsernameOrPassword("Usuário ou senha inválidos")))
        }
    }

    // MARK: Private

    @Injected(RepositoryContainer.loginRepository) private var repository

    private var cancellable: AnyCancellable?
    private var cancellable2 = Set<AnyCancellable>()

    private func saveToken(response: Login?) {
        if let session = response,
           let id = session.id,
           let accessToken = session.accessToken,
           let refreshToken = session.refreshToken,
           let expiresIn = session.expiresIn {
            let dateFormatter = ISO8601DateFormatter()

            KeychainDataSource.id.set(id)
            KeychainDataSource.accessToken.set(accessToken)
            KeychainDataSource.refreshToken.set(refreshToken)
            KeychainDataSource.expiresIn.set(dateFormatter.string(from: expiresIn))

//            WatchConnectivityManager.shared.send("Hello World!\n\(Date().ISO8601Format())")

            WatchConnectivityManager.shared.$state
                .receive(on: DispatchQueue.main)
                .sink { state in
                    switch state {
                    case .activated:
                        WatchConnectivityManager.shared.send("Hello World!\n\(Date().ISO8601Format())")
                    default:
                        break
                    }
                }.store(in: &cancellable2)

            WatchConnectivityManager.shared.activateSession()
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
