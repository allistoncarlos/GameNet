//
//  GameNetApp.swift
//  GameNet
//
//  Created by Alliston Aleixo on 25/06/22.
//

import Combine
import GameNet_Keychain
import SwiftUI

@main
struct GameNetApp: App {

    // MARK: Lifecycle

    init() {
        WatchConnectivityManager.shared.$message
            .receive(on: RunLoop.main)
            .sink(receiveValue: { message in
                DispatchQueue.main.async {
                    if message["ASK_FOR_CREDENTIALS"] != nil {
                        if KeychainDataSource.hasValidToken() {
                            if let id = KeychainDataSource.id.get(),
                               let accessToken = KeychainDataSource.accessToken.get(),
                               let refreshToken = KeychainDataSource.refreshToken.get(),
                               let expiresIn = KeychainDataSource.expiresIn.get() {
                                let responseMessage = [
                                    id,
                                    accessToken,
                                    refreshToken,
                                    expiresIn
                                ]

                                WatchConnectivityManager.shared.sendMessage(
                                    message: responseMessage,
                                    key: "AUTH_INFO"
                                )
                            }
                        } else {
                            WatchConnectivityManager.shared.sendMessage(
                                message: "NOT_LOGGED",
                                key: "NOT_LOGGED"
                            )
                        }
                    }
                }
            })
            .store(in: &cancellables)
    }

    // MARK: Internal

    static let pageSizePhone = 21
    static let pageSizePad = 30
    static let pageSize = UIDevice.current.userInterfaceIdiom == .phone ? pageSizePhone : pageSizePad
    static let dateFormat = "dd/MM/yyyy HH:mm"

    var body: some Scene {
        WindowGroup {
            resultView()
                .onAppear {
                    WatchConnectivityManager.shared.activateSession()
                }
        }
    }

    // MARK: Private

    private var cancellables = Set<AnyCancellable>()

    @MainActor
    private func resultView() -> AnyView {
        return KeychainDataSource.hasValidToken() ?
            AnyView(LoginRouter.makeHomeView()) :
            AnyView(LoginRouter.makeLoginView())
//        return AnyView(LoginRouter.makeLoginView())
    }
}
