//
//  GameNetApp.swift
//  GameNet
//
//  Created by Alliston Aleixo on 25/06/22.
//

import Combine
import Factory
import SwiftUI
import FirebaseCore
#if os(iOS)
import UIKit
#endif

@main
struct GameNetApp: App {
    @State private var isRemoteConfigLoaded = false

    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

#if canImport(WatchConnectivity) && os(iOS)
        WatchConnectivityManager.shared.activateSession()
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                await WatchPhoneCoordinator.shared.pushPlayingGamesToWatch()
            }
        }
#endif
    }

    static let dateTimeFormat = "dd/MM/yyyy HH:mm"
    static let dateFormat = "dd/MM/yyyy"
    static let shortDateFormat = "dd/MM"
    static let timeFormat = "HH:mm"

    static var pageSize: Int {
        PlatformMetrics.pageSize
    }

    static let hudConfig = GameNetHUDConfig.loading

    var body: some Scene {
        WindowGroup {
            if isRemoteConfigLoaded {
                resultView()
                    .onAppear {
#if canImport(WatchConnectivity) && os(iOS)
                        WatchConnectivityManager.shared.activateSession()
                        Task { @MainActor in
                            await WatchPhoneCoordinator.shared.pushPlayingGamesToWatch()
                        }
#endif
                        WidgetSharedStore.syncFromKeychain()
                        #if os(iOS)
                        Task {
                            await GameplayLiveActivityManager.syncFromStore()
                        }
                        #endif
                    }
                    #if os(macOS)
                    .macOSWindowStyle()
                    #endif
            } else {
                ProgressView("Carregando...")
                    .task {
                        await FirebaseRemoteConfig.loadRemoteConfigValues()
                        isRemoteConfigLoaded = true
                    }
            }
        }
        #if os(macOS)
        .defaultSize(width: 1100, height: 720)
        .windowResizability(.contentMinSize)
        #endif
    }

    @MainActor
    private func resultView() -> AnyView {
        return Container.shared.tokenDataSource().hasValidToken() ?
            AnyView(LoginRouter.makeHomeView()) :
            AnyView(LoginRouter.makeLoginView())
    }
}
