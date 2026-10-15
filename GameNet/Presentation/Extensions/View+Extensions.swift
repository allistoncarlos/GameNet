//
//  View+Extensions.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

private struct GameCoverTransitionNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace.ID? = nil
}

private struct DashboardUsesOuterPaddingKey: EnvironmentKey {
    static let defaultValue = true
}

private struct DashboardCardFillsHeightKey: EnvironmentKey {
    static let defaultValue = false
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

    var dashboardCardFillsHeight: Bool {
        get { self[DashboardCardFillsHeightKey.self] }
        set { self[DashboardCardFillsHeightKey.self] = newValue }
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

    func dashboardFillRowHeight() -> some View {
        environment(\.dashboardCardFillsHeight, true)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    func dashboardCardHeight() -> some View {
        modifier(DashboardCardHeightModifier())
    }

    @ViewBuilder
    func dashboardScrollTopInset() -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            contentMargins(.top, 0, for: .scrollContent)
        } else {
            self
        }
    }

    /// Esconde o scroller nativo. No Mac, `.scrollIndicators(.never)` é ignorado.
    func hideScrollIndicatorsAlways() -> some View {
        modifier(HideScrollIndicatorsModifier())
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

private struct HideScrollIndicatorsModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollIndicators(.never)
            #if os(macOS)
            .overlay {
                MacScrollIndicatorHider()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(false)
            }
            #endif
    }
}

#if os(macOS)
private struct MacScrollIndicatorHider: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        Probe()
    }

    func updateNSView(_ view: NSView, context: Context) {
        (view as? Probe)?.hideScrollers()
    }

    final class Probe: NSView {
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            hideScrollers()
            DispatchQueue.main.async { [weak self] in
                self?.hideScrollers()
            }
        }

        override func layout() {
            super.layout()
            hideScrollers()
        }

        func hideScrollers() {
            var current: NSView? = superview
            while let view = current {
                if let scrollView = view as? NSScrollView {
                    hide(scrollView)
                    hideDescendants(of: scrollView)
                    return
                }
                current = view.superview
            }
        }

        private func hideDescendants(of root: NSView) {
            for subview in root.subviews {
                if let scrollView = subview as? NSScrollView {
                    hide(scrollView)
                }
                hideDescendants(of: subview)
            }
        }

        private func hide(_ scrollView: NSScrollView) {
            scrollView.hasHorizontalScroller = false
            scrollView.hasVerticalScroller = false
            scrollView.autohidesScrollers = true
            scrollView.scrollerStyle = .overlay
            scrollView.horizontalScroller?.alphaValue = 0
            scrollView.verticalScroller?.alphaValue = 0
            scrollView.horizontalScroller?.isHidden = true
            scrollView.verticalScroller?.isHidden = true
        }
    }
}
#endif

private struct DashboardCardHeightModifier: ViewModifier {
    @Environment(\.dashboardCardFillsHeight) private var fillsHeight

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: fillsHeight ? .infinity : nil, alignment: .top)
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
