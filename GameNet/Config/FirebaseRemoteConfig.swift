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
    
    case testeEnabled = "TesteEnabled"
}

@MainActor
class FirebaseRemoteConfig {
    static private(set) var testeEnabled: Bool = false
    
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
                    if status == .successFetchedFromRemote || status == .successUsingPreFetchedData {
                        FirebaseRemoteConfig.testeEnabled =
                            remoteConfig[RemoteConfigParameters.testeEnabled.rawValue]
                            .boolValue
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
}
