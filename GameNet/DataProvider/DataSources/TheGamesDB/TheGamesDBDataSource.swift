//
//  TheGamesDBDataSource.swift
//  GameNet
//

import Foundation

protocol TheGamesDBDataSourceProtocol {
    var hasAPIKey: Bool { get }
    func searchGames(name: String, platformId: Int?) async -> [TheGamesDBGame]
    func boxartURL(gameId: Int) async -> URL?
    func platforms() async -> [(id: Int, name: String, alias: String?)]
    func downloadImage(from url: URL) async -> Data?
}

final class TheGamesDBDataSource: TheGamesDBDataSourceProtocol {
    private let session: URLSession
    private let apiKey: String

    init(
        session: URLSession = .shared,
        apiKey: String = Bundle.main.object(forInfoDictionaryKey: "THEGAMESDB_API_KEY") as? String ?? ""
    ) {
        self.session = session
        self.apiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func searchGames(name: String, platformId: Int?) async -> [TheGamesDBGame] {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "fields", value: "id,game_title,release_date,platform")
        ]

        if let platformId {
            items.append(URLQueryItem(name: "filter[platform]", value: String(platformId)))
        }

        guard let url = makeURL(path: "/v1/Games/ByGameName", items: items),
              let response: TheGamesDBGamesResponse = await get(url) else {
            return []
        }

        return response.data?.games ?? []
    }

    func boxartURL(gameId: Int) async -> URL? {
        let items = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "games_id", value: String(gameId)),
            URLQueryItem(name: "filter[type]", value: "boxart")
        ]

        guard let url = makeURL(path: "/v1/Games/Images", items: items),
              let response: TheGamesDBImagesResponse = await get(url) else {
            return nil
        }

        let images = response.data?.images?[String(gameId)] ?? []
        let front = images.first { $0.side?.lowercased() == "front" } ?? images.first
        guard let filename = front?.filename,
              let base = response.data?.baseURL?.original ?? response.data?.baseURL?.large else {
            return nil
        }

        return URL(string: base + filename)
    }

    func platforms() async -> [(id: Int, name: String, alias: String?)] {
        let items = [URLQueryItem(name: "apikey", value: apiKey)]
        guard let url = makeURL(path: "/v1/Platforms", items: items),
              let response: TheGamesDBPlatformsResponse = await get(url) else {
            return []
        }

        return (response.data?.platforms ?? [:]).values.map {
            (id: $0.id, name: $0.name, alias: $0.alias)
        }
    }

    func downloadImage(from url: URL) async -> Data? {
        do {
            let (data, response) = try await session.data(from: url)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                return nil
            }
            return data
        } catch {
            return nil
        }
    }

    var hasAPIKey: Bool {
        !apiKey.isEmpty && apiKey != "YOUR_KEY"
    }

    private func makeURL(path: String, items: [URLQueryItem]) -> URL? {
        var components = URLComponents(string: "https://api.thegamesdb.net\(path)")
        components?.queryItems = items
        return components?.url
    }

    private func get<T: Decodable>(_ url: URL) async -> T? {
        guard hasAPIKey else { return nil }

        do {
            let (data, response) = try await session.data(from: url)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                return nil
            }
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }
}

private struct TheGamesDBGamesResponse: Decodable {
    let data: TheGamesDBGamesData?
}

private struct TheGamesDBGamesData: Decodable {
    let games: [TheGamesDBGame]?
}

extension TheGamesDBGame: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name = "game_title"
        case platformId = "platform"
        case released = "release_date"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        platformId = try container.decodeIfPresent(Int.self, forKey: .platformId)
        platformName = nil
        released = try container.decodeIfPresent(String.self, forKey: .released)
        boxartURL = nil
    }
}

private struct TheGamesDBImagesResponse: Decodable {
    let data: TheGamesDBImagesData?
}

private struct TheGamesDBImagesData: Decodable {
    let baseURL: TheGamesDBBaseURL?
    let images: [String: [TheGamesDBImage]]?

    enum CodingKeys: String, CodingKey {
        case baseURL = "base_url"
        case images
    }
}

private struct TheGamesDBBaseURL: Decodable {
    let original: String?
    let large: String?
    let medium: String?
    let small: String?
    let thumb: String?
}

private struct TheGamesDBImage: Decodable {
    let type: String?
    let side: String?
    let filename: String?
}

private struct TheGamesDBPlatformsResponse: Decodable {
    let data: TheGamesDBPlatformsData?
}

private struct TheGamesDBPlatformsData: Decodable {
    let platforms: [String: TheGamesDBPlatform]?
}

private struct TheGamesDBPlatform: Decodable {
    let id: Int
    let name: String
    let alias: String?
}
