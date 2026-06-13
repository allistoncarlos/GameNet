//
//  FunDataSource.swift
//  GameNet
//
//  Created by Alliston Aleixo on 13/06/26.
//

import Foundation

// MARK: - FunDataSourceProtocol

protocol FunDataSourceProtocol {
    func fetchRating(userGameId: String) async -> GameFunRating?
}

// MARK: - FunDataSource

struct FunDataSource: FunDataSourceProtocol {
    func fetchRating(userGameId: String) async -> GameFunRating? {
        // A API de Fun ainda não está exposta em GameNet_Network.
        // Quando o endpoint estiver disponível, implementar a chamada via NetworkManager aqui.
        nil
    }
}
