//
//  UIImage+AccentColor.swift
//  GameNet
//
//  Created by Alliston Aleixo on 13/06/26.
//

import SwiftUI

#if os(iOS)
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

        var bestScore: CGFloat = 0
        var bestUIColor = UIColor(Color.main)

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
                bestUIColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
            }
        }

        guard bestScore > 0 else { return fallback }

        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        bestUIColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        return Color(
            uiColor: UIColor(
                hue: hue,
                saturation: min(saturation * 1.1, 1),
                brightness: min(max(brightness, 0.45), 0.82),
                alpha: 1
            )
        )
    }
}

enum CoverAccentColor {
    static func from(urlString: String) async -> Color {
        guard
            let url = URL(string: urlString),
            let (data, _) = try? await URLSession.shared.data(from: url),
            let image = UIImage(data: data)
        else {
            return .main
        }

        return image.accentColor()
    }
}
#endif
