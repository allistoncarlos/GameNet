import Foundation

protocol Storage {
    func write(_ data: Data, for key: PersistenceKeys)
    func delete(key: PersistenceKeys)

    func get(_ key: PersistenceKeys) -> Data?
}

protocol StorageFactoryProtocol: AnyObject {
    func storage(of type: StorageType) -> Storage
}

class StorageFactory: StorageFactoryProtocol {
    private let keychain: Keychain
    private var encryptionIsEnabled: Bool {
        #if DEVELOPMENT || MOCK
        return false
        #else
        return true
        #endif
    }

    init(keychain: Keychain) {
        self.keychain = keychain
    }

    func storage(of type: StorageType) -> Storage {
        switch type {
        case .keyChain:
            return KeychainStorage(keychain: keychain)
        case .userDefaults:
            return UserDefaultStorage()
        }
    }
}
