//
//  LoginResponseDTO.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation

public struct LoginResponseDTO: Codable {

    // MARK: Public

    public var id: String
    public var firstName: String
    public var lastName: String
    public var accessToken: String
    public var refreshToken: String
    public var expiresIn: Date

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case lastName
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}
