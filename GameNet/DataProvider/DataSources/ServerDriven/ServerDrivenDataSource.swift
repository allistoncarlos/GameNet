//
//  ServerDrivenDataSourceProtocol.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/11/24.
//


import Foundation

// MARK: - ServerDrivenDataSourceProtocol

protocol ServerDrivenDataSourceProtocol {
    func fetch(slug: String) async -> ServerDriven?
}

// MARK: - ServerDrivenDataSource

class ServerDrivenDataSource: ServerDrivenDataSourceProtocol {
    func fetch(slug: String) async -> ServerDriven? {
        if let apiResult = await NetworkManager.shared
            .performRequest(
                responseType: ServerDrivenResponseDTO.self,
                endpoint: .serverDriven(slug: slug)
            ) {
            return apiResult.toServerDriven()
        }

        return nil
    }
}
