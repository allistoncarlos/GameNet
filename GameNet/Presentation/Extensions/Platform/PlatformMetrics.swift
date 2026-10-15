//
//  PlatformMetrics.swift
//  GameNet
//

import SwiftUI

#if canImport(UIKit) && !os(macOS)
import UIKit
#endif

#if os(macOS)
import AppKit
#endif

enum DashboardLayoutStyle: Equatable {
    /// iPhone em retrato — a vitrine e o empilhamento atuais.
    case compact
    /// iPhone em paisagem, iPad e Mac — grade de cards.
    case regular
}

enum PlatformMetrics {
    static let pageSizePhone = 21
    static let pageSizePad = 30
    static let pageSizeMac = 36

    static var pageSize: Int {
        #if os(macOS)
        return pageSizeMac
        #elseif os(iOS)
        #if canImport(UIKit)
        return UIDevice.current.userInterfaceIdiom == .phone ? pageSizePhone : pageSizePad
        #else
        return pageSizePad
        #endif
        #else
        return pageSizePad
        #endif
    }

    static var isPhone: Bool {
        #if os(iOS) && canImport(UIKit)
        return UIDevice.current.userInterfaceIdiom == .phone
        #else
        return false
        #endif
    }

    static func dashboardLayoutStyle(
        width: CGFloat,
        isPhone: Bool,
        isLandscape: Bool
    ) -> DashboardLayoutStyle {
        if isPhone && !isLandscape {
            return .compact
        }

        if width < 600 && !isLandscape {
            return .compact
        }

        return .regular
    }

    static func dashboardUsesCompactLayout(width: CGFloat, isLandscape: Bool = false) -> Bool {
        dashboardLayoutStyle(width: width, isPhone: isPhone, isLandscape: isLandscape) == .compact
    }

    /// Dois cards na mesma linha só quando cada um tem ~400pt.
    /// Abaixo disso o card de horas vira uma coluna só e o outro estica no vazio.
    static func dashboardUsesPairedCards(width: CGFloat) -> Bool {
        width >= 900
    }

    static func usesWideDetailLayout(width: CGFloat, isLandscape: Bool) -> Bool {
        isLandscape || width >= 700
    }

    static func contentMaxWidth(for width: CGFloat) -> CGFloat {
        switch width {
        case ..<600:
            return width
        case 600..<900:
            return min(width - 48, 820)
        case 900..<1400:
            return min(width - 80, 1100)
        default:
            return 1280
        }
    }

    static func dashboardContentMaxWidth(for width: CGFloat) -> CGFloat {
        switch width {
        case ..<700:
            return width
        case 700..<1100:
            return min(width - 32, 1040)
        case 1100..<1600:
            return min(width - 48, 1280)
        default:
            return 1440
        }
    }

    static func horizontalPadding(for width: CGFloat) -> CGFloat {
        switch width {
        case ..<600:
            return 12
        case 600..<1200:
            return 20
        default:
            return 32
        }
    }

    static func gameGridColumns(for width: CGFloat) -> [GridItem] {
        let minimum: CGFloat
        switch width {
        case ..<500:
            minimum = 100
        case 500..<800:
            minimum = 120
        case 800..<1200:
            minimum = 130
        default:
            minimum = 140
        }

        return [GridItem(.adaptive(minimum: minimum), spacing: 20)]
    }

    static func listCardColumns(for width: CGFloat) -> [GridItem] {
        let count = width >= 800 ? 2 : 1
        return Array(repeating: GridItem(.flexible(), spacing: 12), count: count)
    }

    static func gamesByPlatformColumns(for width: CGFloat) -> [GridItem] {
        let count: Int
        switch width {
        case ..<700:
            count = 1
        case 700..<1100:
            count = 2
        default:
            count = 3
        }

        return Array(repeating: GridItem(.flexible(), spacing: 10), count: count)
    }

    static func annualChartVisibleDays(for width: CGFloat) -> Int {
        switch width {
        case ..<600:
            return 15
        case 600..<900:
            return 24
        case 900..<1400:
            return 40
        default:
            return 56
        }
    }

    static func annualChartHeight(compact: Bool, isLandscape: Bool) -> CGFloat {
        if compact {
            return 340
        }

        return isLandscape ? 260 : 360
    }

    static func playingCoverMaxWidth(for width: CGFloat, cardHeight: CGFloat, compact: Bool) -> CGFloat? {
        guard !compact else { return nil }

        let availableHeight = cardHeight - 100
        let heightBasedWidth = availableHeight * (2.0 / 3.0)

        switch width {
        case ..<900:
            return min(heightBasedWidth, 280)
        case 900..<1200:
            return min(heightBasedWidth, 340)
        default:
            return min(heightBasedWidth, 400)
        }
    }

    static func playingCardHeight(for width: CGFloat, compact: Bool) -> CGFloat {
        if compact {
            return min(PlatformScreen.height * 0.45, 420)
        }

        switch width {
        case ..<900:
            return 480
        case 900..<1200:
            return 520
        default:
            return 560
        }
    }

    /// Pôster 2:3 da vitrine. A altura é limitada pela tela — em paisagem a largura
    /// do card não pode gerar um pôster maior que o viewport.
    static func vitrineCoverSize(
        cardWidth: CGFloat,
        inset: CGFloat,
        compact: Bool,
        isLandscape: Bool,
        screenHeight: CGFloat
    ) -> CGSize {
        let availableWidth = max(cardWidth - inset * 2, 120)
        let shortSide = min(PlatformScreen.width, screenHeight)
        let longSide = max(PlatformScreen.width, screenHeight)

        let maxHeight: CGFloat
        if isLandscape {
            maxHeight = min(max(shortSide - 210, 140), 168)
        } else if compact {
            // iPhone 14 Pro Max (~932pt): pôster ~390pt, o quadro azul ocupa o vão
            // abaixo da nav sem voltar ao width×1.5 (~560pt) que estourava a tela.
            maxHeight = min(longSide * 0.42, 400)
        } else {
            maxHeight = min(longSide * 0.34, 340)
        }

        let width = min(availableWidth, (maxHeight * 2 / 3).rounded())
        return CGSize(width: width, height: (width * 1.5).rounded())
    }
}

private struct ContentWidthModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    func body(content: Content) -> some View {
        GeometryReader { proxy in
            let maxWidth = PlatformMetrics.contentMaxWidth(for: proxy.size.width)

            ScrollView {
                content
                    .frame(maxWidth: maxWidth)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, PlatformMetrics.horizontalPadding(for: proxy.size.width))
            }
        }
    }
}

extension View {
    func adaptiveContentWidth() -> some View {
        modifier(ContentWidthModifier())
    }

    func gameNetContentWidth(for width: CGFloat) -> some View {
        frame(maxWidth: PlatformMetrics.contentMaxWidth(for: width))
            .frame(maxWidth: .infinity)
    }

    func gameNetDashboardWidth(for width: CGFloat) -> some View {
        frame(maxWidth: PlatformMetrics.dashboardContentMaxWidth(for: width))
            .frame(maxWidth: .infinity)
    }

    #if os(macOS)
    func macOSWindowStyle() -> some View {
        frame(minWidth: 640, minHeight: 480)
            .background(
                MacWindowPolicyConfigurator()
                    .frame(width: 0, height: 0)
                    .allowsHitTesting(false)
            )
            .onAppear { MacWindowPolicy.apply() }
    }
    #endif
}

#if os(macOS)
enum MacWindowPolicy {
    static func apply() {
        NSApp.windows.forEach { configure($0, exitFullScreen: true) }
    }

    static func configure(_ window: NSWindow, exitFullScreen: Bool) {
        if exitFullScreen, window.styleMask.contains(.fullScreen) {
            window.toggleFullScreen(nil)
        }

        var behavior = window.collectionBehavior
        behavior.remove(.fullScreenPrimary)
        behavior.insert(.fullScreenNone)
        if window.collectionBehavior != behavior {
            window.collectionBehavior = behavior
        }
    }
}

private struct MacWindowPolicyConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                MacWindowPolicy.configure(window, exitFullScreen: true)
            } else {
                MacWindowPolicy.apply()
            }
        }
        return view
    }

    func updateNSView(_ view: NSView, context: Context) {
        if let window = view.window {
            MacWindowPolicy.configure(window, exitFullScreen: false)
        }
    }
}
#endif
