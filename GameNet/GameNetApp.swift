//
//  GameNetApp.swift
//  GameNet
//
//  Created by Alliston Aleixo on 25/06/22.
//

import Combine
import GameNet_Keychain
import GameNet_Network
import SwiftUI
import TTProgressHUD
import FirebaseCore
import SwiftData

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct GameNetApp: App {
    // MARK: Firebase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var isRemoteConfigLoaded = false

    // MARK: Lifecycle

    init() {
#if canImport(WatchConnectivity)
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
#endif
    }

    // MARK: Internal

    static let pageSizePhone = 21
    static let pageSizePad = 30
    static let pageSize = UIDevice.current.userInterfaceIdiom == .phone ? pageSizePhone : pageSizePad
    static let dateTimeFormat = "dd/MM/yyyy HH:mm"
    static let dateFormat = "dd/MM/yyyy"
    static let shortDateFormat = "dd/MM"
    static let timeFormat = "HH:mm"

    static let hudConfig = TTProgressHUDConfig(
        title: "Carregando",
        caption: "Aguarde enquanto os dados\nsão retornados do servidor"
    )
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Platform.self
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if isRemoteConfigLoaded {
                resultView(modelContext: sharedModelContainer.mainContext)
                    .onAppear {
#if canImport(WatchConnectivity)
                        WatchConnectivityManager.shared.activateSession()
#endif
                    }
            } else {
                ProgressView("Carregando...")
                    .task {
                        await FirebaseRemoteConfig.loadRemoteConfigValues()
                        
                        isRemoteConfigLoaded = true
                    }
            }
        }
    }

    // MARK: Private

    private var cancellables = Set<AnyCancellable>()

    @MainActor
    private func resultView(modelContext: ModelContext) -> AnyView {
        return KeychainDataSource.hasValidToken() ?
            AnyView(LoginRouter.makeHomeView(modelContext: modelContext)) :
            AnyView(LoginRouter.makeLoginView())
    }
}
