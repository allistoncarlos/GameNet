//
//  LoginView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 25/06/22.
//

import SwiftUI

// MARK: - LoginView

struct LoginView: View {
    @State var username: String = ""
    @State var password: String = ""

    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        ZStack {
            if viewModel.uiState == .success {
                viewModel.homeView()
            } else {
                NavigationView {
                    Form {
                        TextField("Username", text: $username)
                        SecureField("Password", text: $password) {
                            viewModel.login(email: username, password: password)
                        }

                        Section(
                            footer:
                            Button("Login") {
                                viewModel.login(email: username, password: password)
                            }
                            .disabled(username.isEmpty || password.isEmpty || viewModel.uiState == .loading)
                            .buttonStyle(MainButtonStyle())
                        ) {
                            EmptyView()
                        }
                    }
                    .navigationTitle("Login")
                }

                if case let LoginUIState.error(error) = viewModel.uiState {
                    Text("")
                        .alert(isPresented: .constant(true)) {
                            Alert(
                                title: Text("GameNet"),
                                message: Text(error),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                }
            }
        }
    }
}

// MARK: - LoginView_Previews

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            LoginView(viewModel: LoginViewModel()).preferredColorScheme($0)
        }
    }
}
