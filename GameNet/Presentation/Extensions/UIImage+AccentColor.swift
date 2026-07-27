//
//  UIImage+AccentColor.swift
//  GameNet
//
//  Created by Alliston Aleixo on 13/06/26.
//

import SwiftUI

#if canImport(UIKit) && !os(macOS)
import UIKit

extension UIImage {
    func accentColor(fallback: Color = .main) -> Color {
        guard let cgImage else { return fallback }

        let sampleSize = 32
        let bytesPerPixel = 4
        let bytesPerRow = sampleSize * bytesPerPixel
        var rawData = [UInt8](repeating: 0, count: sampleSize * sampleSize * bytesPerPixel)

        guard let context = CGContext(
            data: &rawData,
            width: sampleSize,
            height: sampleSize,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else {
            return fallback
        }

        context.interpolationQuality = .medium
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: sampleSize, height: sampleSize))

        return CoverAccentColor.fromSampledPixels(rawData, bytesPerPixel: bytesPerPixel, fallback: fallback)
    }
}
#endif

#if os(macOS)
import AppKit

extension NSImage {
    func accentColor(fallback: Color = .main) -> Color {
        guard
            let cgImage = cgImage(forProposedRect: nil, context: nil, hints: nil)
        else {
            return fallback
        }

        let sampleSize = 32
        let bytesPerPixel = 4
        let bytesPerRow = sampleSize * bytesPerPixel
        var rawData = [UInt8](repeating: 0, count: sampleSize * sampleSize * bytesPerPixel)

        guard let context = CGContext(
            data: &rawData,
            width: sampleSize,
            height: sampleSize,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else {
            return fallback
        }

        context.interpolationQuality = .medium
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: sampleSize, height: sampleSize))

        return CoverAccentColor.fromSampledPixels(rawData, bytesPerPixel: bytesPerPixel, fallback: fallback)
    }
}
#endif

enum CoverAccentColor {
    static func from(urlString: String) async -> Color {
        guard
            let url = URL(string: urlString),
            let (data, _) = try? await URLSession.shared.data(from: url)
        else {
            return .main
        }

        #if canImport(UIKit) && !os(macOS)
        guard let image = UIImage(data: data) else { return .main }
        return image.accentColor()
        #elseif os(macOS)
        guard let image = NSImage(data: data) else { return .main }
        return image.accentColor()
        #else
        return .main
        #endif
    }

    static func fromSampledPixels(
        _ rawData: [UInt8],
        bytesPerPixel: Int,
        fallback: Color
    ) -> Color {
        var bestScore: CGFloat = 0
        var bestHue: CGFloat = 0
        var bestSaturation: CGFloat = 0
        var bestBrightness: CGFloat = 0

        for offset in stride(from: 0, to: rawData.count, by: bytesPerPixel) {
            let red = CGFloat(rawData[offset]) / 255
            let green = CGFloat(rawData[offset + 1]) / 255
            let blue = CGFloat(rawData[offset + 2]) / 255

            let maxChannel = max(red, green, blue)
            let minChannel = min(red, green, blue)
            let saturation = maxChannel == 0 ? 0 : (maxChannel - minChannel) / maxChannel
            let brightness = maxChannel

            guard saturation > 0.18, brightness > 0.22, brightness < 0.92 else { continue }

            let score = (saturation * 0.75) + (brightness * 0.25)
            if score > bestScore {
                bestScore = score
                var hue: CGFloat = 0
                var sat: CGFloat = 0
                var bri: CGFloat = 0
                var alpha: CGFloat = 0

                #if canImport(UIKit) && !os(macOS)
                UIColor(red: red, green: green, blue: blue, alpha: 1)
                    .getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
                #else
                NSColor(red: red, green: green, blue: blue, alpha: 1)
                    .usingColorSpace(.deviceRGB)?
                    .getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
                #endif

                bestHue = hue
                bestSaturation = sat
                bestBrightness = bri
            }
        }

        guard bestScore > 0 else { return fallback }

        return Color(
            hue: Double(bestHue),
            saturation: Double(min(bestSaturation * 1.1, 1)),
            brightness: Double(min(max(bestBrightness, 0.45), 0.82))
        )
    }
}
