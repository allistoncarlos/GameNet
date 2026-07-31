//
//  WatchCoverImageExporter.swift
//  GameNet
//
//  Created by Alliston Aleixo on 27/07/26.
//

#if os(iOS)
import Foundation
import ImageIO
import UIKit
import UniformTypeIdentifiers

enum WatchCoverImageExporter {
    /// Tamanho de exibição na `PlayingGamesView` (pt).
    static let displayPointSize: CGFloat = 140

    /// Tamanho em pixels do JPEG exportado. Mantido enxuto para caber várias capas
    /// no `updateApplicationContext` (limite ~262KB) e no reply do `sendMessage`
    /// (limite ~65KB). Aprox. 1.7× o tamanho de exibição — nítido no Watch, ~6-9KB por capa.
    static let exportPixelSize: CGFloat = 240

    private static let compressionQuality: CGFloat = 0.72

    private static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 12
        config.requestCachePolicy = .useProtocolCachePolicy
        config.urlCache = URLCache(
            memoryCapacity: 20 * 1024 * 1024,
            diskCapacity: 100 * 1024 * 1024
        )
        return URLSession(configuration: config)
    }()

    static func thumbnails(for games: [WatchPlayingGame]) async -> [String: Data] {
        await withTaskGroup(of: (String, Data?).self) { group in
            for game in games {
                group.addTask {
                    let data = await thumbnailData(for: game.coverURL)
                    return (game.id, data)
                }
            }

            var result: [String: Data] = [:]
            for await (gameId, data) in group {
                if let data {
                    result[gameId] = data
                }
            }
            return result
        }
    }

    static func thumbnailData(for urlString: String) async -> Data? {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let url = URL(string: trimmed) else { return nil }

        var request = URLRequest(url: url)
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15",
            forHTTPHeaderField: "User-Agent"
        )
        request.setValue(
            "image/webp,image/avif,image/heic,image/apng,image/png,image/jpeg,image/*,*/*;q=0.8",
            forHTTPHeaderField: "Accept"
        )

        do {
            let (data, response) = try await session.data(for: request)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                return nil
            }
            return jpegThumbnail(from: data)
        } catch {
            return nil
        }
    }

    /// Decodifica qualquer formato suportado pelo ImageIO (WebP, HEIC, AVIF, PNG, GIF, JPEG…)
    /// e reencoda como JPEG compacto — o único formato que o Watch consome com 100% de confiança.
    static func jpegThumbnail(from data: Data) -> Data? {
        guard !data.isEmpty,
              let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }

        let thumbnailOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: exportPixelSize,
            kCGImageSourceShouldCacheImmediately: true
        ]

        guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(
            source,
            0,
            thumbnailOptions as CFDictionary
        ) else {
            return nil
        }

        let outputData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            outputData,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            return nil
        }

        let destinationOptions: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ]
        CGImageDestinationAddImage(destination, thumbnail, destinationOptions as CFDictionary)

        guard CGImageDestinationFinalize(destination) else { return nil }

        return outputData as Data
    }
}
#endif
