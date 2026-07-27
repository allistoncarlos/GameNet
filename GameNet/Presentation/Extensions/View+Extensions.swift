//
//  View+Extensions.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import SwiftUI

private struct GameCoverTransitionNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace.ID? = nil
}

extension EnvironmentValues {
    var gameCoverTransitionNamespace: Namespace.ID? {
        get { self[GameCoverTransitionNamespaceKey.self] }
        set { self[GameCoverTransitionNamespaceKey.self] = newValue }
    }
}

extension View {
    func navigationView(title: String?, color: Color = .main) -> some View {
        modifier(NavigationViewModifier(title: title, color: color))
    }

    func gameCoverTransitionNamespace(_ namespace: Namespace.ID) -> some View {
        environment(\.gameCoverTransitionNamespace, namespace)
    }

    func gameCoverTransitionSource(id: String?) -> some View {
        modifier(GameCoverTransitionSourceModifier(id: id))
    }

    func gameDetailZoomTransition(gameId: String) -> some View {
        modifier(GameDetailZoomTransitionModifier(gameId: gameId))
    }

    func gameDetailNavigationBar(color: Color = .main) -> some View {
        #if os(macOS)
        navigationTitle("")
        #else
        navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        #endif
    }
}

private struct GameCoverTransitionSourceModifier: ViewModifier {
    @Environment(\.gameCoverTransitionNamespace) private var namespace
    let id: String?

    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 18.0, *), let id, let namespace {
            content
                .matchedTransitionSource(id: id, in: namespace)
        } else {
            content
        }
        #else
        content
        #endif
    }
}

private struct GameDetailZoomTransitionModifier: ViewModifier {
    @Environment(\.gameCoverTransitionNamespace) private var namespace
    let gameId: String

    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 18.0, *), let namespace {
            content
                .gameDetailNavigationBar()
                .navigationTransition(.zoom(sourceID: gameId, in: namespace))
        } else {
            content
                .gameDetailNavigationBar()
        }
        #else
        content
            .gameDetailNavigationBar()
        #endif
    }
}
