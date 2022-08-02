//
//  LoginRepository.swift
//  GameNet
//
//  Created by Alliston Aleixo on 02/08/22.
//

import Factory
import Foundation

// MARK: - LoginRepositoryProtocol

protocol LoginRepositoryProtocol {
    func login(login: Login) async -> Login?
}

// MARK: - LoginRepository

struct LoginRepository: LoginRepositoryProtocol {
    // MARK: Internal

    func login(login: Login) async -> Login? {
        do {
            return await dataSource.login(loginRequest: try login.toRequest())
        } catch {
            print(error)
            return nil
        }
    }

    // MARK: Private

    @Injected(DataSourceContainer.loginDataSource) private var dataSource
}
