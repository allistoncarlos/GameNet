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

    var body: some View {
        NavigationView {
            Form {
                TextField("Username", text: $username)
                SecureField("Password", text: $password) {
                    handleLogin()
                }

                Section(footer:
                    Button("Login") {
                        handleLogin()
                    }
                    .buttonStyle(MainButtonStyle())
                ) {
                    EmptyView()
                }
            }
            .navigationTitle("Login")
        }
    }

    func handleLogin() {
        print("LOGGED IN")
    }
}

// MARK: - LoginView_Previews

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            LoginView().preferredColorScheme($0)
        }
    }
}
