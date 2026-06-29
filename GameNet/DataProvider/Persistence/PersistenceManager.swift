import Foundation

protocol PersistenceManagerProtocol: AnyObject {
    func persist<T>(_ value: T?, key: PersistenceKeys, storageType: StorageType) where T: Codable
    func retrieve<T>(_ key: PersistenceKeys, storageType: StorageType) -> T? where T: Codable
    func delete(_ key: PersistenceKeys, storageType: StorageType)
}

final class PersistenceManager: PersistenceManagerProtocol {
    private var storageFactory: StorageFactoryProtocol

    init(storageFactory: StorageFactoryProtocol) {
        self.storageFactory = storageFactory
    }

    func persist<T>(_ value: T?, key: PersistenceKeys, storageType: StorageType) where T: Codable {
        let storage = storageFactory.storage(of: storageType)

        guard let value = value else {
            return
        }

        guard let data = convertToData(value) else {
            return
        }

        storage.write(data, for: key)
    }

    private func convertToData<T: Codable>(_ value: T) -> Data? {
        let entry = StorageEntry(value: value)
        return try? JSONEncoder().encode(entry)
    }

    func retrieve<T>(_ key: PersistenceKeys, storageType: StorageType) -> T? where T: Codable {
        let storage = storageFactory.storage(of: storageType)
        return self.retrieve(key, storage: storage)
    }

    private func retrieve<T>(_ key: PersistenceKeys, storage: Storage) -> T? where T: Codable {
        guard
            let data = storage.get(key),
            let storageEntry: StorageEntry<T> = entry(from: data) else
        {
            return nil
        }

        return storageEntry.value
    }

    private func entry<T: Codable>(from data: Data) -> StorageEntry<T>? {
        return try? JSONDecoder().decode(StorageEntry<T>.self, from: data)
    }

    func delete(_ key: PersistenceKeys, storageType: StorageType) {
        let storage = storageFactory.storage(of: storageType)
        storage.delete(key: key)
    }
}
