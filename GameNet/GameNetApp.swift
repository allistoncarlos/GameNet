//
//  GameNetApp.swift
//  GameNet
//
//  Created by Alliston Aleixo on 25/06/22.
//

import GameNet_Keychain
import SwiftUI

@main
struct GameNetApp: App {

    // MARK: Internal

    static let pageSizePhone = 21
    static let pageSizePad = 30
    static let pageSize = UIDevice.current.userInterfaceIdiom == .phone ? pageSizePhone : pageSizePad

    var body: some Scene {
        WindowGroup {
            resultView()
        }
    }

    // MARK: Private

    @MainActor
    private func resultView() -> AnyView {
        return AnyView(LoginRouter.makeLoginView())
    }
}
