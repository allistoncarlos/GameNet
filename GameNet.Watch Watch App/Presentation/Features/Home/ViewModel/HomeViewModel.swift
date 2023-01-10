//
//  HomeViewModel.swift
//  GameNet.Watch Watch App
//
//  Created by Alliston Aleixo on 10/01/23.
//

import Foundation
import GameNet_Keychain

class HomeViewModel: ObservableObject {

    // MARK: Lifecycle

    init() {
        hasValidAccessToken = KeychainDataSource.hasValidToken()
    }

    // MARK: Internal

    @Published var hasValidAccessToken: Bool = false
}
