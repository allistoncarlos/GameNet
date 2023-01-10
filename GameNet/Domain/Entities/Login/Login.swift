//
//  Login.swift
//  GameNet
//
//  Created by Alliston Aleixo on 02/08/22.
//

import Foundation
import GameNet_Network

// MARK: - Login

struct Login: Equatable {
    // MARK: Lifecycle

    init(
        id: String,
        firstName: String,
        lastName: String,
        accessToken: String,
        refreshToken: String,
        expiresIn: Date
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        username = ""
        password = ""
    }

    init(username: String, password: String) {
        self.username = username
        self.password = password
        id = ""
        firstName = ""
        lastName = ""
        accessToken = ""
        refreshToken = ""
        expiresIn = nil
    }

    // MARK: Internal

    let id: String?
    let username: String?
    let password: String?
    let firstName: String?
    let lastName: String?
    let accessToken: String?
    let refreshToken: String?
    let expiresIn: Date?

    func toRequest() throws -> LoginRequest {
        if let username = username,
           let password = password {
            return LoginRequest(username: username, password: password)
        }

        throw RequestError.invalidData
    }
}

extension LoginResponse {
    func toLogin() -> Login {
        return Login(
            id: id,
            firstName: firstName,
            lastName: lastName,
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: expiresIn
        )
    }
}
