//
//  PlatformRouter.swift
//  GameNet
//
//  Created by Alliston Aleixo on 24/08/22.
//

import SwiftUI

@MainActor
enum PlatformRouter {
    static func makeCreatePlatformView(navigationPath: Binding<NavigationPath>) -> some View {
        let editPlatformViewModel = EditPlatformViewModel(platform: Platform(id: nil, name: String()))

        return EditPlatformView(viewModel: editPlatformViewModel, navigationPath: navigationPath)
    }

    static func makePlatformDetailView(
        navigationPath: Binding<NavigationPath>,
        platform: Platform
    ) -> some View {
        return PlatformDetailView(
            platform: platform,
            viewModel: GamesViewModel(platformId: platform.id),
            navigationPath: navigationPath
        )
    }

    static func goBackToPlatforms(navigationPath: Binding<NavigationPath>) {
        navigationPath.wrappedValue.removeLast()
    }
}
