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

private struct DashboardUsesOuterPaddingKey: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    var gameCoverTransitionNamespace: Namespace.ID? {
        get { self[GameCoverTransitionNamespaceKey.self] }
        set { self[GameCoverTransitionNamespaceKey.self] = newValue }
    }

    var dashboardUsesOuterPadding: Bool {
        get { self[DashboardUsesOuterPaddingKey.self] }
        set { self[DashboardUsesOuterPaddingKey.self] = newValue }
    }
}

extension View {
    func navigationView(title: String?, color: Color = .main) -> some View {
        modifier(NavigationViewModifier(title: title, color: color))
    }

    func gameCoverTransitionNamespace(_ namespace: Namespace.ID) -> some View {
        environment(\.gameCoverTransitionNamespace, namespace)
    }

    @ViewBuilder
    func dashboardOuterPadding() -> some View {
        modifier(DashboardOuterPaddingModifier())
    }

    @ViewBuilder
    func dashboardScrollTopInset() -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            contentMargins(.top, 0, for: .scrollContent)
        } else {
            self
        }
    }

    func gameCoverTransitionSource(id: String?) -> some View {
        modifier(GameCoverTransitionSourceModifier(id: id))
    }

    func gameDetailZoomTransition(gameId: String) -> some View {
        modifier(GameDetailZoomTransitionModifier(gameId: gameId))
    }

    func gameDetailNavigationBar(color: Color = .main) -> some View {
        #if os(iOS)
        navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .gameNetInlineToolbarTitle()
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        #else
        navigationTitle("")
        #endif
    }
}

private struct DashboardOuterPaddingModifier: ViewModifier {
    @Environment(\.dashboardUsesOuterPadding) private var usesOuterPadding

    func body(content: Content) -> some View {
        if usesOuterPadding {
            content.padding()
        } else {
            content
        }
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
