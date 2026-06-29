enum PersistenceKeys: String, CustomStringConvertible {
    var description: String { rawValue }

    case id
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
    case expiresIn = "expires_in"
}
