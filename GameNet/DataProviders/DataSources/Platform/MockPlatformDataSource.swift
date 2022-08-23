//
//  MockPlatformDataSource.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/08/22.
//

import Foundation
import GameNet_Network

class MockPlatformDataSource: PlatformDataSourceProtocol {
    // MARK: Internal

    func fetchData() async -> [Platform]? {
        return MockPlatformDataSource.platforms
    }

    func fetchData(id: String) async -> Platform? {
        MockPlatformDataSource.platforms.first { platform in
            platform.id == id
        }
    }

    func savePlatform(id: String?, platform: Platform) async -> Platform? {
        if let id = id,
           let index = MockPlatformDataSource.platforms.firstIndex(where: { $0.id == id }) {
            MockPlatformDataSource.platforms[index] = platform
        } else {
            let newPlatform = Platform(id: "\(UUID())", name: platform.name)
            MockPlatformDataSource.platforms.append(newPlatform)
        }

        return platform
    }

    // MARK: Private

    private static var platforms = [
        Platform(id: "1", name: "Nintendo Switch"),
        Platform(id: "2", name: "PlayStation 5"),
    ]
}
