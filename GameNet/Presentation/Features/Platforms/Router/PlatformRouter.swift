//
//  PlatformRouter.swift
//  GameNet
//
//  Created by Alliston Aleixo on 24/08/22.
//

#if os(iOS)
import GameNet_Network
import SwiftUI
import SwiftData

@MainActor
enum PlatformRouter {
    static func makeEditPlatformView(
        modelContext: ModelContext,
        navigationPath: Binding<NavigationPath>,
        platform: Platform?
    ) -> some View {
        let emptyPlatform = Platform(id: nil, name: String())
        let editPlatformViewModel = EditPlatformViewModel(platform: platform ?? emptyPlatform, modelContext: modelContext)
        
        return EditPlatformView(viewModel: editPlatformViewModel, navigationPath: navigationPath)
    }

    static func goBackToPlatforms(navigationPath: Binding<NavigationPath>) {
        navigationPath.wrappedValue.removeLast()
    }
}
#endif
