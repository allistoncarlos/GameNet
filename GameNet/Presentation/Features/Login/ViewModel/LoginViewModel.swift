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
import WatchConnectivity

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

            WatchConnectivityManager.shared.$state
                .receive(on: RunLoop.main)
                .sink { state in
                    switch state {
                    case .activated:
                        do {
                            let context = [
                                id,
                                accessToken,
                                refreshToken,
                                formattedExpiresIn
                            ]

                            try WatchConnectivityManager.shared.updateApplicationContext(message: context, key: "AUTH_INFO")
                        } catch WCError.notReachable {
                            print("NOT REACHABLE")
                        } catch WCError.companionAppNotInstalled {
                            print("COMPANION APP NOT INSTALLED")
                        } catch WCError.watchAppNotInstalled {
                            print("WATCH APP NOT INSTALLED")
                        } catch WCError.sessionNotActivated {
                            print("SESSION NOT ACTIVATED")
                        } catch {
                            print("DEFAULT ERROR")
                        }
                    default:
                        break
                    }
                }.store(in: &cancellable)

            WatchConnectivityManager.shared.activateSession()
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
