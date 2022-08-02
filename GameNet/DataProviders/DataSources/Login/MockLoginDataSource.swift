//
//  MockLoginDataSource.swift
//  GameNet
//
//  Created by Alliston Aleixo on 02/08/22.
//

import Foundation
import GameNet_Network

class MockLoginDataSource: LoginDataSourceProtocol {
    func login(loginRequest: LoginRequest) async -> Login? {
        if loginRequest.username == "teste" &&
            loginRequest.password == "teste" {
            return Login(
                id: "1",
                firstName: "Nome",
                lastName: "Nome",
                accessToken: "123",
                refreshToken: "1234",
                expiresIn: Date.distantFuture
            )
        }

        return nil
    }
}
