//
//  MockPlatformRepository.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/08/22.
//

import Foundation
import GameNet_Network

struct MockPlatformRepository: PlatformRepositoryProtocol {
    // MARK: Internal

    static func reset() {
        platforms = Defaults.platforms
    }

    func fetchData(cache: Bool = true) async -> [Platform]? {
        return MockPlatformRepository.platforms
    }

    func fetchData(id: String) async -> Platform? {
        MockPlatformRepository.platforms.first { platform in
            platform.id == id
        }
    }

    func savePlatform(id: String?, platform: Platform) async -> Platform? {
        if let id = id,
           let index = MockPlatformRepository.platforms.firstIndex(where: { $0.id == id }) {
            MockPlatformRepository.platforms[index] = platform
        } else {
            let newPlatform = Platform(id: "\(UUID())", name: platform.name)
            MockPlatformRepository.platforms.append(newPlatform)
        }

        return platform
    }

    // MARK: Private

    private enum Defaults {
        static let platforms = [
            Platform(id: "1", name: "Nintendo Switch"),
            Platform(id: "2", name: "PlayStation 5"),
        ]
    }

    private static var platforms = Defaults.platforms
}
