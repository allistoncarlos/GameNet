//
//  PlatformMetrics.swift
//  GameNet
//

import SwiftUI

#if canImport(UIKit) && !os(macOS)
import UIKit
#endif

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

    static func dashboardCardColumns(for width: CGFloat) -> Int {
        switch width {
        case ..<700:
            return 1
        case 700..<1100:
            return 2
        default:
            return 3
        }
    }

    static var isPhone: Bool {
        #if os(iOS) && canImport(UIKit)
        return UIDevice.current.userInterfaceIdiom == .phone
        #else
        return false
        #endif
    }

    static func dashboardUsesCompactLayout(width: CGFloat) -> Bool {
        #if os(iOS) && canImport(UIKit)
        if UIDevice.current.userInterfaceIdiom == .phone {
            return true
        }
        #endif
        return width < 600
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

    #if os(macOS)
    func macOSWindowStyle() -> some View {
        frame(minWidth: 640, minHeight: 480)
    }
    #endif
}
