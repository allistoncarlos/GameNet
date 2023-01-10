//
//  LoginViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 30/07/22.
//

import Factory
import GameNet_Keychain
import SwiftUI

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
