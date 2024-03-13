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

#if canImport(WatchConnectivity)
import WatchConnectivity
#endif

// MARK: - LoginError

enum LoginError: Error, Equatable {
    case invalidUsernameOrPassword
}

// MARK: - LoginViewModel

@MainActor
class LoginViewModel: ObservableObject {

    // MARK: Internal

    @Published var state: LoginState = .idle

    func login(username: String, password: String) async {
        state = .loading

        let result = await repository.login(login: Login(username: username, password: password))

        if let result {
            saveToken(response: result)

            state = .success(result)
        } else {
            state = .error(.invalidUsernameOrPassword)
        }
    }

    // MARK: Private

    @Injected(RepositoryContainer.loginRepository) private var repository
    private var cancellable = Set<AnyCancellable>()

    private func saveToken(response: Login?) {
        if let session = response,
           let id = session.id,
           let accessToken = session.accessToken,
           let refreshToken = session.refreshToken,
           let expiresIn = session.expiresIn {
            let dateFormatter = ISO8601DateFormatter()

            let formattedExpiresIn = dateFormatter.string(from: expiresIn)

            KeychainDataSource.id.set(id)
            KeychainDataSource.accessToken.set(accessToken)
            KeychainDataSource.refreshToken.set(refreshToken)
            KeychainDataSource.expiresIn.set(formattedExpiresIn)

            DispatchQueue.main.async {
                let message = [
                    id,
                    accessToken,
                    refreshToken,
                    formattedExpiresIn
                ]

#if canImport(WatchConnectivity)
                WatchConnectivityManager.shared.sendMessage(
                    message: message,
                    key: "AUTH_INFO"
                )
#endif
            }
        } else {
            KeychainDataSource.clear()
        }
    }

}

extension LoginViewModel {
    @MainActor
    func homeView() -> some View {
        return LoginRouter.makeHomeView()
    }
}
