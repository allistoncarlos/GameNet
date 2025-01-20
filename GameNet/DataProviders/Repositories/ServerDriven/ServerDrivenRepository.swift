//
//  ServerDrivenRepositoryProtocol.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/11/24.
//


import Factory
import Foundation
import GameNet_Network

// MARK: - ServerDrivenRepositoryProtocol

protocol ServerDrivenRepositoryProtocol {
    func fetch(slug: String) async -> ServerDriven?
}

// MARK: - GameplaySessionRepository

struct ServerDrivenRepository: ServerDrivenRepositoryProtocol {

    // MARK: Internal

    func fetch(slug: String) async -> ServerDriven? {
        return await dataSource.fetch(slug: slug)
    }

    // MARK: Private

    @Injected(DataSourceContainer.serverDrivenDataSource) private var dataSource
}
