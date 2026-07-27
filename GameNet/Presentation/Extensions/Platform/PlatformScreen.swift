//
//  PlatformScreen.swift
//  GameNet
//

import SwiftUI

enum PlatformScreen {
    static var bounds: CGRect {
        #if os(macOS)
        if let screen = NSScreen.main {
            return screen.visibleFrame
        }
        return CGRect(x: 0, y: 0, width: 1280, height: 800)
        #elseif canImport(UIKit)
        return UIScreen.main.bounds
        #else
        return CGRect(x: 0, y: 0, width: 390, height: 844)
        #endif
    }

    static var width: CGFloat { bounds.width }
    static var height: CGFloat { bounds.height }
}

#if os(macOS)
import AppKit
#endif

#if canImport(UIKit) && !os(macOS)
import UIKit
#endif
