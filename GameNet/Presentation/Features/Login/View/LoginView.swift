//
//  LoginView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 25/06/22.
//

import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showErrorAlert = false

    @ObservedObject var viewModel: LoginViewModel

    private var canLogin: Bool {
        !username.isEmpty && !password.isEmpty && viewModel.state != .loading
    }

    var body: some View {
        Group {
            if case .success = viewModel.state {
                viewModel.homeView()
            } else {
                loginScreen
            }
        }
    }

    private var loginScreen: some View {
        GeometryReader { proxy in
            ZStack {
                loginBackground

                ScrollView {
                    VStack(spacing: 0) {
                        Spacer(minLength: verticalSpacing(for: proxy.size.height))

                        loginCard
                            .frame(maxWidth: cardMaxWidth(for: proxy.size.width))
                            .padding(.horizontal, PlatformMetrics.horizontalPadding(for: proxy.size.width))

                        Spacer(minLength: 24)
                    }
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height)
                }
            }
        }
        .overlay {
            GameNetProgressHUD($isLoading, config: GameNetApp.hudConfig)
        }
        .onChange(of: viewModel.state) { _, state in
            isLoading = state == .loading

            if case .error = state {
                showErrorAlert = true
            }
        }
        .alert("GameNet", isPresented: $showErrorAlert) {
            Button("OK") {
                viewModel.state = .idle
            }
        } message: {
            Text("Usuário ou senha inválidos")
        }
        #if os(macOS)
        .frame(minWidth: 640, minHeight: 480)
        #endif
    }

    private var loginBackground: some View {
        LinearGradient(
            colors: [
                Color.main.opacity(0.28),
                Color.primaryCardBackground,
                Color.secondaryCardBackground.opacity(0.45)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var loginCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            header

            VStack(alignment: .leading, spacing: 16) {
                usernameField
                passwordField
            }

            Button("Entrar") {
                submitLogin()
            }
            .disabled(!canLogin)
            .buttonStyle(MainButtonStyle())
            #if os(macOS)
            .keyboardShortcut(.defaultAction)
            #endif
        }
        .padding(28)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.primaryCardBackground)
                .shadow(color: .black.opacity(0.14), radius: 24, y: 10)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.main.opacity(0.12), lineWidth: 1)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.main)

                Text("GameNet")
                    .font(.cardTitle)
            }

            Text("Entre para gerenciar sua biblioteca de jogos")
                .font(.dashboardGameSubtitle)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var usernameField: some View {
        loginField(title: "Usuário") {
            TextField("", text: $username)
                #if os(iOS)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textContentType(.username)
                #elseif os(macOS)
                .textContentType(.username)
                #endif
        }
    }

    private var passwordField: some View {
        loginField(title: "Senha") {
            SecureField("", text: $password)
                #if os(iOS)
                .textContentType(.password)
                #elseif os(macOS)
                .textContentType(.password)
                .onSubmit { submitLogin() }
                #endif
        }
        .onSubmit { submitLogin() }
    }

    private func loginField<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            content()
                .textFieldStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.secondaryCardBackground.opacity(0.65))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.main.opacity(0.08), lineWidth: 1)
                }
        }
    }

    private func submitLogin() {
        guard canLogin else { return }

        Task {
            await viewModel.login(username: username, password: password)
        }
    }

    private func cardMaxWidth(for width: CGFloat) -> CGFloat {
        min(420, max(320, width - 48))
    }

    private func verticalSpacing(for height: CGFloat) -> CGFloat {
        #if os(macOS)
        max(32, (height - 420) / 2)
        #else
        max(24, (height - 380) / 3)
        #endif
    }
}

#Preview("Dark Mode") {
    LoginView(viewModel: LoginViewModel()).preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    LoginView(viewModel: LoginViewModel()).preferredColorScheme(.light)
}

#Preview("macOS") {
    LoginView(viewModel: LoginViewModel())
        .frame(width: 900, height: 640)
}
