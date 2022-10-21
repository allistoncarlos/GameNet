//
//  GameNetApp.swift
//  GameNet
//
//  Created by Alliston Aleixo on 25/06/22.
//

import SwiftUI

@main
struct GameNetApp: App {
    static let pageSizePhone = 21
    static let pageSizePad = 30
    static let pageSize = UIDevice.current.userInterfaceIdiom == .phone ? pageSizePhone : pageSizePad

    var body: some Scene {
        WindowGroup {
            LoginView(viewModel: LoginViewModel())
        }
    }
}
