//
//  GameNetApp+Storage.swift
//  GameNet
//

import Factory
import Foundation

extension Container {
    private var keychainFactory: Factory<Keychain> { self { Keychain() } }
    private var storageFactory: Factory<StorageFactoryProtocol> { self { StorageFactory(keychain: self.keychainFactory.resolve()) } }
    var persistence: Factory<PersistenceManagerProtocol> { self { PersistenceManager(storageFactory: self.storageFactory.resolve()) } }
}
