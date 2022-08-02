//
//  MockLoginRepository.swift
//  GameNet
//
//  Created by Alliston Aleixo on 02/08/22.
//

import Foundation

struct MockLoginRepository: LoginRepositoryProtocol {
    func login(login: Login) async -> Login? {
        if login.username == "teste" &&
            login.password == "teste" {
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
