//
//  PlayingGamesViewModel.swift
//  GameNet.Watch Watch App
//
//  Created by Alliston Aleixo on 06/01/23.
//

import Combine
import Factory
import Foundation
import GameNet_Network
import SwiftUI

// MARK: - APIError

enum APIError: Error {
    case server(String)
}

// MARK: - PlatformDataSourceProtocol

protocol PlatformDataSourceProtocol {
    func fetchData() async -> [Platform]?
    func fetchData(id: String) async -> Platform?
    func savePlatform(id: String?, platform: Platform) async -> Platform?
}

// MARK: - PlatformDataSource

class PlatformDataSource: PlatformDataSourceProtocol {
    func fetchData() async -> [Platform]? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<PagedResult<PlatformResponse>>.self,
                endpoint: .platforms
            ) {
            if apiResult.ok {
                return apiResult.data.result
                    .compactMap { $0.toPlatform() }
                    .sorted(by: { $1.name.uppercased() > $0.name.uppercased() })
            }
        }

        return nil
    }

    func fetchData(id: String) async -> Platform? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<PlatformResponse>.self,
                endpoint: .platform(id: id)
            ) {
            if apiResult.ok {
                return apiResult.data.toPlatform()
            }
        }

        return nil
    }

    func savePlatform(id: String?, platform: Platform) async -> Platform? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: APIResult<PlatformResponse>.self,
                endpoint: .savePlatform(id: id, data: platform.toRequest())
            ) {
            if apiResult.ok {
                return apiResult.data.toPlatform()
            }
        }

        return nil
    }
}

// MARK: - DataSourceContainer

class DataSourceContainer: SharedContainer {
    static let platformDataSource = Factory<PlatformDataSourceProtocol> { PlatformDataSource() }
}

// MARK: - PlatformRepositoryProtocol

protocol PlatformRepositoryProtocol {
    func fetchData() async -> [Platform]?
    func fetchData(id: String) async -> Platform?
    func savePlatform(id: String?, platform: Platform) async -> Platform?
}

// MARK: - PlatformRepository

struct PlatformRepository: PlatformRepositoryProtocol {

    // MARK: Internal

    func fetchData() async -> [Platform]? {
        return await dataSource.fetchData()
    }

    func fetchData(id: String) async -> Platform? {
        return await dataSource.fetchData(id: id)
    }

    func savePlatform(id: String?, platform: Platform) async -> Platform? {
        return await dataSource.savePlatform(id: id, platform: platform)
    }

    // MARK: Private

    @Injected(DataSourceContainer.platformDataSource) private var dataSource
}

// MARK: - RepositoryContainer

class RepositoryContainer: SharedContainer {
    static let platformRepository = Factory<PlatformRepositoryProtocol> { PlatformRepository() }
}

// MARK: - PlatformsUIState

enum PlatformsUIState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}

// MARK: - PlayingGamesViewModel

class PlayingGamesViewModel: ObservableObject {

    // MARK: Lifecycle

    init() {
        cancellable = publisher
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Received finished")
                case let .failure(error):
                    switch error {
                    case let .server(message):
                        self.uiState = .error(message)
                    }
                }
            } receiveValue: { [weak self] platforms in
                self?.platforms = platforms

                self?.uiState = .success
            }
    }

    deinit {
        cancellable?.cancel()
    }

    // MARK: Public

    public let publisher = PassthroughSubject<[Platform]?, APIError>()

    // MARK: Internal

    @Published var platforms: [Platform]? = nil
    @Published var uiState: PlatformsUIState = .idle

    func fetchData() async {
        uiState = .loading

        // TODO: Tá dando 401 (TRAFEGAR O TOKEN)
        let result = await repository.fetchData()

        if let result = result {
            publisher.send(result)
        } else {
            publisher.send(completion: .failure(.server("Erro no carregamento de dados do servidor")))
        }
    }

    // MARK: Private

    @Injected(RepositoryContainer.platformRepository) private var repository
    private var cancellable: AnyCancellable?
}
