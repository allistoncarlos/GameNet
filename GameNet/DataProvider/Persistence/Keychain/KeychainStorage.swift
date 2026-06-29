import Foundation

final class KeychainStorage: Storage {
    private let keychain: Keychain

    init(keychain: Keychain) {
        self.keychain = keychain
    }

    func get(_ key: PersistenceKeys) -> Data? {
        return (try? keychain.getData(key.rawValue)) ?? nil
    }

    func write(_ data: Data, for key: PersistenceKeys) {
        do {
            try keychain.set(data, key: key.rawValue)
        } catch {
            print("KEYCHAIN ECODING ERROR: \(error)")
        }
    }

    func delete(key: PersistenceKeys) {
        do {
            try keychain.remove(key.rawValue)
        } catch _ {}
    }
}
