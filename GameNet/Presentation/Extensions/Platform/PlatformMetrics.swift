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
