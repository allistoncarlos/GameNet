//
//  RefreshTokenResponse.swift
//
//
//  Created by Alliston Aleixo on 22/01/23.
//

import Foundation

public struct RefreshTokenResponse: Codable {

    // MARK: Public

    public var accessToken: String
    public var refreshToken: String
    public var expiresIn: Date

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}
