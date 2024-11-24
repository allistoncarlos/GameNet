//
//  FirebaseRemoteConfig.swift
//  GameNet
//
//  Created by Alliston Aleixo on 13/11/24.
//

import Foundation
import FirebaseRemoteConfig

enum RemoteConfigParameters: String, CaseIterable, Identifiable {
    var id : String { UUID().uuidString }
    
    case dashboardViewCarousel = "DashboardViewCarousel"
    case toggleGameplaySession = "ToggleGameplaySession"
    case stepperView = "StepperView"
    case serverDrivenDashboard = "ServerDrivenDashboard"
}

@MainActor
class FirebaseRemoteConfig {
    static private(set) var dashboardViewCarousel: Bool = false
    static private(set) var toggleGameplaySession: Bool = false
    static private(set) var stepperView: Bool = false
    static private(set) var serverDrivenDashboard: Bool = false
    
    static var overrideRemoteConfigs: Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "OverrideRemoteConfigs")
    }
    
    private static func setConfigs(_ remoteConfig: RemoteConfig) {
        FirebaseRemoteConfig.dashboardViewCarousel =
            remoteConfig[RemoteConfigParameters.dashboardViewCarousel.rawValue]
            .boolValue
        
        FirebaseRemoteConfig.toggleGameplaySession =
            remoteConfig[RemoteConfigParameters.toggleGameplaySession.rawValue]
            .boolValue

        FirebaseRemoteConfig.stepperView =
            remoteConfig[RemoteConfigParameters.stepperView.rawValue]
            .boolValue
        
        FirebaseRemoteConfig.serverDrivenDashboard =
            remoteConfig[RemoteConfigParameters.serverDrivenDashboard.rawValue]
            .boolValue
    }
    
    private static func setDebugConfigs() {
        let decoder = JSONDecoder()
        if let savedData = UserDefaults.standard.data(forKey: "featureToggles"),
           let debugConfigs = try? decoder.decode([RemoteConfigModel].self, from: savedData) {
            if let dashboardViewCarousel = debugConfigs.first(where: { $0.featureToggle ==
                RemoteConfigParameters.dashboardViewCarousel.rawValue
            }) {
                FirebaseRemoteConfig.dashboardViewCarousel = dashboardViewCarousel.enabled
            }

            if let toggleGameplaySession = debugConfigs.first(where: { $0.featureToggle ==
                RemoteConfigParameters.toggleGameplaySession.rawValue
            }) {
                FirebaseRemoteConfig.toggleGameplaySession = toggleGameplaySession.enabled
            }

            if let stepperView = debugConfigs.first(where: { $0.featureToggle ==
                RemoteConfigParameters.stepperView.rawValue
            }) {
                FirebaseRemoteConfig.stepperView = stepperView.enabled
            }
            
            if let serverDrivenDashboard = debugConfigs.first(where: { $0.featureToggle ==
                RemoteConfigParameters.serverDrivenDashboard.rawValue
            }) {
                FirebaseRemoteConfig.serverDrivenDashboard = serverDrivenDashboard.enabled
            }
        }
    }
    
    private static func fetchAndActivateRemoteConfig() async throws -> RemoteConfigFetchAndActivateStatus {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        
        #if DEBUG
        settings.minimumFetchInterval = 0 // Set to 0 for real-time updates during development/testing
        #else
        settings.minimumFetchInterval = 30
        #endif

        remoteConfig.configSettings = settings
        
        return try await withCheckedThrowingContinuation { continuation in
            remoteConfig.fetchAndActivate {
                status,
                error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    if status == .successFetchedFromRemote ||
                        status == .successUsingPreFetchedData {
                        if overrideRemoteConfigs {
                            #if os(iOS) && DEBUG
                            FirebaseRemoteConfig.setDebugConfigs()
                            #endif
                        } else {
                            FirebaseRemoteConfig.setConfigs(remoteConfig)
                        }
                    }
                    
                    continuation.resume(returning: status)
                }
            }
        }
    }
    
    static func loadRemoteConfigValues() async {
        do {
            let status = try await FirebaseRemoteConfig.fetchAndActivateRemoteConfig()
            switch status {
            case .successFetchedFromRemote:
                print("Configuração obtida do servidor")
            case .successUsingPreFetchedData:
                print("Usando dados previamente obtidos")
            case .error:
                print("Erro ao obter a configuração")
            @unknown default:
                print("Status desconhecido")
            }
        } catch {
            print("Erro ao carregar a configuração: \(error.localizedDescription)")
        }
    }
    
    static func overrideRemoteConfigs(value: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: "OverrideRemoteConfigs")
    }
}
