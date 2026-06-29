import Foundation
import Factory

protocol TokenDataSourceProtocol {
    var id: String? { get }
    var accessToken: String? { get }
    var refreshToken: String? { get }
    var expiresIn: Date? { get }

    func save(login: Login)
    func save(id: String?, accessToken: String, refreshToken: String, expiresIn: Date)
    func clear()
    func hasValidToken() -> Bool
}

struct TokenDataSource: TokenDataSourceProtocol {
    @Injected(\.persistence) private var persistence

    var id: String? { persistence.retrieve(.id, storageType: .keyChain) }
    var accessToken: String? { persistence.retrieve(.accessToken, storageType: .keyChain) }
    var refreshToken: String? { persistence.retrieve(.refreshToken, storageType: .keyChain) }
    var expiresIn: Date? { persistence.retrieve(.expiresIn, storageType: .keyChain) }

    func save(login: Login) {
        guard
            let accessToken = login.accessToken,
            let refreshToken = login.refreshToken,
            let expiresIn = login.expiresIn
        else {
            return
        }

        save(
            id: login.id,
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: expiresIn
        )
    }

    func save(id: String?, accessToken: String, refreshToken: String, expiresIn: Date) {
        persistence.persist(id, key: .id, storageType: .keyChain)
        persistence.persist(accessToken, key: .accessToken, storageType: .keyChain)
        persistence.persist(refreshToken, key: .refreshToken, storageType: .keyChain)
        persistence.persist(expiresIn, key: .expiresIn, storageType: .keyChain)
    }

    func clear() {
        persistence.delete(.id, storageType: .keyChain)
        persistence.delete(.accessToken, storageType: .keyChain)
        persistence.delete(.refreshToken, storageType: .keyChain)
        persistence.delete(.expiresIn, storageType: .keyChain)
    }

    func hasValidToken() -> Bool {
        guard
            let _: String = id,
            let _: String = accessToken,
            let _: String = refreshToken,
            let expiresIn: Date = expiresIn
        else {
            return false
        }

        return expiresIn > .now
    }
}
