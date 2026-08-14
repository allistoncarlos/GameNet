//
//  CoverImageCache.swift
//  GameNet
//
//  Created by Alliston Aleixo on 14/08/26.
//

import Foundation

enum CoverImageCache {
    static let urlCache: URLCache = {
        let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("CoverImages", isDirectory: true)

        return URLCache(
            memoryCapacity: 64 * 1_024 * 1_024,
            diskCapacity: 256 * 1_024 * 1_024,
            directory: directory
        )
    }()

    static func request(for urlString: String) -> URLRequest? {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let url = URL(string: trimmed) else { return nil }
        return URLRequest(url: url)
    }

    static func prefetch(urls: [String]) {
        let uniqueURLs = Array(Set(urls))
        guard !uniqueURLs.isEmpty else { return }

        Task.detached(priority: .utility) {
            await withTaskGroup(of: Void.self) { group in
                for urlString in uniqueURLs {
                    group.addTask {
                        await downloadIfNeeded(urlString)
                    }
                }
            }
        }
    }

    static func cachedData(for urlString: String) -> Data? {
        guard let request = request(for: urlString) else { return nil }
        return urlCache.cachedResponse(for: request)?.data
    }

    static func store(data: Data, response: URLResponse, for urlString: String) {
        guard let request = request(for: urlString) else { return }
        urlCache.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
    }

    private static func downloadIfNeeded(_ urlString: String) async {
        guard let request = request(for: urlString) else { return }
        if urlCache.cachedResponse(for: request) != nil {
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                return
            }

            store(data: data, response: response, for: urlString)
        } catch {
            return
        }
    }
}
