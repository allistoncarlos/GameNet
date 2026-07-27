//
//  PlatformImage.swift
//  GameNet
//

import SwiftUI

enum PlatformImage {
    static func swiftUIImage(from data: Data) -> Image? {
        #if canImport(UIKit) && !os(macOS)
        guard let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
        #elseif os(macOS)
        guard let nsImage = NSImage(data: data) else { return nil }
        return Image(nsImage: nsImage)
        #else
        return nil
        #endif
    }
}

#if os(macOS)
import AppKit
#endif

#if canImport(UIKit) && !os(macOS)
import UIKit
#endif
