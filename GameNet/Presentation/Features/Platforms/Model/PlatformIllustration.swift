//
//  PlatformIllustration.swift
//  GameNet
//

import Foundation

enum PlatformIllustration {
    private static let baseURL = "https://allistoncarlos.blob.core.windows.net/gamenet/platforms"

    static func url(for name: String) -> URL? {
        let slug = Slug.generate(name)
        guard !slug.isEmpty else { return nil }
        return URL(string: "\(baseURL)/\(slug).png")
    }

    static func urlString(for name: String) -> String? {
        url(for: name)?.absoluteString
    }
}
