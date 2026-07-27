//
//  CoverImageLoader.swift
//  GameNet
//
//  Carrega capas remotas em UIImage para texturizar cenas Metal/SceneKit.
//

import Foundation
import UIKit

enum CoverImageLoader {
    private static let cache = NSCache<NSString, UIImage>()

    static func image(from urlString: String) async -> UIImage? {
        guard !urlString.isEmpty else { return nil }

        let key = urlString as NSString
        if let cached = cache.object(forKey: key) {
            return cached
        }

        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            cache.setObject(image, forKey: key)
            return image
        } catch {
            return nil
        }
    }

    static func placeholder(size: CGSize = CGSize(width: 200, height: 300)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.secondarySystemFill.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
