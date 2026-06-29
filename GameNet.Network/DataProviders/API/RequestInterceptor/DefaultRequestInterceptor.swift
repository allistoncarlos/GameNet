//
//  DefaultRequestInterceptor.swift
//
//  Created by Alliston Aleixo on 18/05/22.
//

import Alamofire
import Foundation
import GameNet_Keychain

class DefaultRequestInterceptor: RequestInterceptor {

    let retryLimit = 3
    let retryDelay: TimeInterval = 10

    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var urlRequest = urlRequest

        if let accessToken = KeychainDataSource.accessToken.get() {
            urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            // TODO: COLOCAR AQUI A CHAMADA PRO REFRESH TOKEN
        }

        completion(.success(urlRequest))
    }

    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        let response = request.task?.response as? HTTPURLResponse

        if let statusCode = response?.statusCode,
           (500 ... 599).contains(statusCode),
           request.retryCount < retryLimit {
            completion(.retryWithDelay(retryDelay))
        } else if let statusCode = response?.statusCode,
                  statusCode == 401,
                  request.retryCount < retryLimit {
            if let accessToken = KeychainDataSource.accessToken.get(),
               let refreshToken = KeychainDataSource.refreshToken.get() {
                Task {
                    if let result = await NetworkManager.shared
                        .performRequest(
                            responseType: RefreshTokenResponse.self,
                            endpoint: .refreshToken(data: RefreshTokenRequest(accessToken: accessToken, refreshToken: refreshToken))
                        ) {
                        let dateFormatter = ISO8601DateFormatter()
                        let formattedExpiresIn = dateFormatter.string(from: result.expiresIn)

                        KeychainDataSource.accessToken.set(result.accessToken)
                        KeychainDataSource.refreshToken.set(result.refreshToken)
                        KeychainDataSource.expiresIn.set(formattedExpiresIn)

                        return completion(.retryWithDelay(retryDelay))
                    }
                }
            }

        } else {
            return completion(.doNotRetry)
        }
    }

}
