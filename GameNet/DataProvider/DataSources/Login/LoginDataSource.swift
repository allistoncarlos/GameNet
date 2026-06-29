//
//  LoginDataSource.swift
//  GameNet
//
//  Created by Alliston Aleixo on 02/08/22.
//

import Foundation

// MARK: - LoginDataSourceProtocol

protocol LoginDataSourceProtocol {
    func login(loginRequest: LoginRequest) async -> Login?
}

// MARK: - LoginDataSource

class LoginDataSource: LoginDataSourceProtocol {
    func login(loginRequest: LoginRequest) async -> Login? {
        if let result = await NetworkManager.shared
            .performRequest(
                responseType: LoginResponseDTO.self,
                endpoint: .login(data: loginRequest)
            ) {
            return result.toLogin()
        }

        return nil
    }
}
