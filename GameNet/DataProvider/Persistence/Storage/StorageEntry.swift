struct StorageEntry<T: Codable>: Codable {
    let value: T

    init(value: T) {
        self.value = value
    }
}
