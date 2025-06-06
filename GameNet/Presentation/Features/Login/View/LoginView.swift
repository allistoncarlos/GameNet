//
//  LoginView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 25/06/22.
//

import SwiftUI
import TTProgressHUD

// MARK: - LoginView

struct LoginView: View {
    @State var username: String = ""
    @State var password: String = ""
    @State var isLoading = false

    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        ZStack {
            if case .success = viewModel.state {
                viewModel.homeView()
            } else {
                NavigationView {
                    Form {
                        TextField("Username", text: $username)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password) {
                            Task {
                                await viewModel.login(username: username, password: password)
                            }
                        }

                        Section(
                            footer:
                            Button("Login") {
                                Task {
                                    await viewModel.login(username: username, password: password)
                                }
                            }
                            .disabled(username.isEmpty || password.isEmpty || viewModel.state == .loading)
                            .buttonStyle(MainButtonStyle())
                        ) {
                            EmptyView()
                        }
                    }
                    .overlay(
                        TTProgressHUD($isLoading, config: GameNetApp.hudConfig)
                    )
                    .onChange(of: viewModel.state) { _, state in
                        isLoading = state == .loading
                    }
                    .navigationTitle("Login")
                }
                .navigationViewStyle(.stack)

                if case let LoginState.error(error) = viewModel.state {
                    alertView(error)
                }
            }
        }
    }

    func alertView(_ error: LoginError) -> AnyView {
        var errorMessage = ""

        switch error {
        case .invalidUsernameOrPassword:
            errorMessage = "Usuário ou senha inválidos"
        }

        return AnyView(Text("")
            .alert(isPresented: .constant(true)) {
                Alert(
                    title: Text("GameNet"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"), action: { viewModel.state = .idle })
                )
            }
        )
    }

}

// MARK: - Previews

#Preview("Dark Mode") {
    LoginView(viewModel: LoginViewModel()).preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    LoginView(viewModel: LoginViewModel()).preferredColorScheme(.light)
}
