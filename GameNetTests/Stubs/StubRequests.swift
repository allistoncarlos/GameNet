//
//  StubRequests.swift
//  GameNetTests
//
//  Created by Alliston Aleixo on 02/08/22.
//

@testable import GameNet
import OHHTTPStubs
import OHHTTPStubsSwift

final class StubRequests {
    /// Host the app is actually configured to call (from `API_PATH`), so stubs
    /// keep matching even when the configured environment changes.
    private static let configuredAPIHost: String? = URL(string: APIConstants.apiPath)?.host

    func stubJSONResponse(
        jsonObject: [String: Any?],
        header: [String: String]?,
        statusCode: Int32,
        absoluteStringWord: String,
        slowConnection: Bool = false
    ) {
        stub(condition: { urlRequest -> Bool in
            guard let absoluteString = urlRequest.url?.absoluteString else { return false }

            if absoluteString.contains(absoluteStringWord) {
                return true
            }

            if let host = Self.configuredAPIHost, absoluteString.contains(host) {
                return true
            }

            return false
        }) { _ -> HTTPStubsResponse in
            let response = HTTPStubsResponse(jsonObject: jsonObject, statusCode: statusCode, headers: header)

            if slowConnection {
                return response.responseTime(OHHTTPStubsDownloadSpeedGPRS)
            }

            return response
        }
    }
}
