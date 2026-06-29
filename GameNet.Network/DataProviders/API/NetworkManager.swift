//
//  NetworkManager.swift
//
//  Created by Alliston Aleixo on 18/05/22.
//

import Foundation
import GameNet_Keychain

// MARK: - Encodable + Data pretty print helpers

extension Encodable {
    func prettyPrintJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let encodedData = try? encoder.encode(self) else {
            return nil
        }

        return String(decoding: encodedData, as: UTF8.self)
    }
}

extension Data {
    func prettyPrintJSON() -> String? {
        guard let object = try? JSONSerialization.jsonObject(with: self) else {
            return nil
        }

        guard let serializedData = try? JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys]
        ) else {
            return nil
        }

        return String(decoding: serializedData, as: UTF8.self)
    }
}

// MARK: - NetworkError

public enum NetworkError: Error {
    case httpCode(Int)
}

// MARK: - NetworkManager

public class NetworkManager {

    // MARK: Public

    public static let shared = NetworkManager()

    @discardableResult
    public func performRequest<T: Decodable>(
        responseType: T.Type,
        endpoint: GameNetAPI,
        cache: Bool = false,
        retryCount: Int = 0
    ) async -> T? {
        do {
            var urlRequest = try endpoint.asURLRequest()
            urlRequest.cachePolicy = cache ? .returnCacheDataElseLoad : .reloadIgnoringLocalCacheData

            if let accessToken = KeychainDataSource.accessToken.get() {
                urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }

            print("ENDPOINT: /\(endpoint.method.rawValue) \(endpoint.path)")
            print("REQUEST: \n: \(urlRequest.httpBody?.prettyPrintJSON() ?? "")")

            let (data, response) = try await session.data(for: urlRequest)
            print("RESPONSE: \(data.prettyPrintJSON() ?? "")")

            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            switch httpResponse.statusCode {
            case 200..<300:
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                return try decoder.decode(T.self, from: data)

            case 401 where retryCount < retryLimit && !endpoint.isRefreshToken:
                if await refreshTokens() {
                    return await performRequest(
                        responseType: responseType,
                        endpoint: endpoint,
                        cache: cache,
                        retryCount: retryCount + 1
                    )
                }

            case 500..<600 where retryCount < retryLimit:
                try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                return await performRequest(
                    responseType: responseType,
                    endpoint: endpoint,
                    cache: cache,
                    retryCount: retryCount + 1
                )

            default:
                throw NetworkError.httpCode(httpResponse.statusCode)
            }

        } catch {
            print(error)
            return nil
        }

        return nil
    }

    @discardableResult
    public func performUploadGame(data: GameEditRequest) async -> APIResult<GameEditResponse>? {
        do {
            let endpoint: GameNetAPI = .saveGame(data: data)

            guard let url = try endpoint.asURLRequest().url else {
                return nil
            }

            let boundary = "Boundary-\(UUID().uuidString)"

            var urlRequest = URLRequest(url: url)
            urlRequest.method = endpoint.method
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            if let accessToken = KeychainDataSource.accessToken.get() {
                urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }

            urlRequest.httpBody = makeMultipartBody(boundary: boundary, data: data)

            let (responseData, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                return nil
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(APIResult<GameEditResponse>.self, from: responseData)
        } catch {
            print(error)
            return nil
        }
    }

    // MARK: Internal

    let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.requestCachePolicy = .returnCacheDataElseLoad

        return URLSession(configuration: configuration)
    }()

    // MARK: Private

    private let retryLimit = 3
    private let retryDelay: TimeInterval = 10

    private func makeMultipartBody(boundary: String, data: GameEditRequest) -> Data {
        var body = Data()

        func appendField(name: String, value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        appendField(name: "name", value: data.name)
        appendField(name: "platformId", value: data.platformId)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"file.jpeg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data.cover)
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        return body
    }

    private func refreshTokens() async -> Bool {
        guard let accessToken = KeychainDataSource.accessToken.get(),
              let refreshToken = KeychainDataSource.refreshToken.get() else {
            return false
        }

        guard let result = await performRequest(
            responseType: RefreshTokenResponse.self,
            endpoint: .refreshToken(data: RefreshTokenRequest(accessToken: accessToken, refreshToken: refreshToken))
        ) else {
            return false
        }

        let dateFormatter = ISO8601DateFormatter()
        let formattedExpiresIn = dateFormatter.string(from: result.expiresIn)

        KeychainDataSource.accessToken.set(result.accessToken)
        KeychainDataSource.refreshToken.set(result.refreshToken)
        KeychainDataSource.expiresIn.set(formattedExpiresIn)

        return true
    }

}
