//
//  FeatureToggleViewModel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 13/11/24.
//

import Foundation

@MainActor
class FeatureToggleViewModel: ObservableObject {
    var featureToggles: [RemoteConfigModel] = []

    init() {
        featureToggles = fetchData()
    }

    private func fetchData() -> [RemoteConfigModel] {
        let decoder = JSONDecoder()
        if let savedData = UserDefaults.standard.data(forKey: "featureToggles"),
           let savedConfigs = try? decoder.decode([RemoteConfigModel].self, from: savedData) {
            let remoteConfigs = RemoteConfigParameters.allCases.map {
                RemoteConfigModel(featureToggle: $0.rawValue, enabled: false)
            }

            return remoteConfigs.count > savedConfigs.count ? remoteConfigs : savedConfigs
        }
        
        return RemoteConfigParameters.allCases.map {
            RemoteConfigModel(featureToggle: $0.rawValue, enabled: false)
        }
    }
    
    func save(overrideRemoteConfigs: Bool) {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(featureToggles) {
            UserDefaults.standard.set(encodedData, forKey: "featureToggles")
        }

        FirebaseRemoteConfig.overrideRemoteConfigs(value: overrideRemoteConfigs)
        
        featureToggles = fetchData()
    }
    
    func removeAllData() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        featureToggles = fetchData()
    }
}
