//
//  PlatformRouter.swift
//  GameNet
//
//  Created by Alliston Aleixo on 24/08/22.
//

import GameNet_Network
import SwiftUI

enum PlatformRouter {
    static func makeEditPlatformView(platform: Platform?) -> some View {
        let emptyPlatform = Platform(id: nil, name: String())
        let editPlatformViewModel = EditPlatformViewModel(platform: platform ?? emptyPlatform)

        return EditPlatformView(viewModel: editPlatformViewModel)
    }
}
