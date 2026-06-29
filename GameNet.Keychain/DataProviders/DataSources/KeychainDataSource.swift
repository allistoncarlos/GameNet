//
//  KeychainDataSource.swift
//
//  Created by Alliston Aleixo on 20/05/22.
//

import Foundation
import KeychainAccess

class KeychainConstants {
    static let keychainIdentifier = "gamenet.azurewebsites.net"
}

public enum KeychainDataSource: String {
    case id
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
    case expiresIn = "expires_in"

    private var keychain: Keychain {
        var identifier: String = KeychainConstants.keychainIdentifier

        return Keychain(service: identifier)
    }

    public func set(_ str: String) {
        keychain[rawValue] = str
    }

    public func get() -> String? {
        return keychain[rawValue]
    }

    public func remove() {
        try? keychain.remove(rawValue)
    }

    public static func clear() {
        id.remove()
        accessToken.remove()
        refreshToken.remove()
        expiresIn.remove()
    }

    public static func hasValidToken() -> Bool {
        if id.get() != nil &&
            accessToken.get() != nil &&
            refreshToken.get() != nil,
           let expiresIn = expiresIn.get()?.toDate(),
           expiresIn > NSDate.init() as Date {
            return true
        }

        return false
    }
}
