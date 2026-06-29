import Foundation

final class UserDefaultStorage: Storage {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

    func get(_ key: PersistenceKeys) -> Data? {
        return userDefaults.object(forKey: key.rawValue) as? Data
    }

    func write(_ data: Data, for key: PersistenceKeys) {
        self.userDefaults.set(data, forKey: key.rawValue)
    }

    func delete(key: PersistenceKeys) {
        self.userDefaults.removeObject(forKey: key.rawValue)
    }
}
