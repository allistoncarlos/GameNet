//
//  GameNetAPI.swift
//
//  Created by Alliston Aleixo on 18/05/22.
//

import Foundation

// MARK: - HTTPMethod

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - ParameterEncoder

public protocol ParameterEncoder {
    func encode<Parameters: Encodable>(_ parameters: Parameters, into request: URLRequest) throws -> URLRequest
}

public struct EmptyResponse: Decodable {}

public class JSONParameterEncoder: ParameterEncoder {
    let encoder: JSONEncoder

    public init() {
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }

    public func encode<Parameters: Encodable>(_ parameters: Parameters, into request: URLRequest) throws -> URLRequest {
        var urlRequest = request

        let data = try encoder.encode(parameters)
        urlRequest.httpBody = data

        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return urlRequest
    }
}

public class URLEncodedFormParameterEncoder: ParameterEncoder {
    public init() {}

    public func encode<Parameters: Encodable>(_ parameters: Parameters, into request: URLRequest) throws -> URLRequest {
        var urlRequest = request

        if request.httpMethod != "GET" {
            let data = try JSONEncoder().encode(parameters)
            let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]

            let formData = dictionary.compactMap { key, value -> String? in
                guard let encodedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                      let encodedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                    return nil
                }
                return "\(encodedKey)=\(encodedValue)"
            }.joined(separator: "&")

            urlRequest.httpBody = formData.data(using: .utf8)

            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            }
        }

        return urlRequest
    }
}

// MARK: - URLRequestConvertible

public protocol URLRequestConvertible {
    func asURLRequest() throws -> URLRequest
}

extension String: URLRequestConvertible {
    public func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: self) else {
            throw URLError(.badURL)
        }
        return URLRequest(url: url)
    }

    func asURL() throws -> URL {
        guard let url = URL(string: self) else {
            throw URLError(.badURL)
        }
        return url
    }
}

extension URLRequest {
    var method: HTTPMethod? {
        get {
            guard let httpMethod = httpMethod else { return nil }
            return HTTPMethod(rawValue: httpMethod)
        }
        set {
            httpMethod = newValue?.rawValue
        }
    }
}

// MARK: - APIConstants

internal enum APIConstants {
    static let apiPath: String = (Bundle.main.infoDictionary!["API_PATH"] as? String)!

    static let userResource = "user"
    static let dashboardResource = "dashboard"
    static let gameResource = "usergame"
    static let gameplaySessionResource = "gameplaysession"
    static let platformResource = "platform"
    static let listResource = "list"
    static let serverDrivenResource = "serverdriven"
}

// MARK: - GameNetAPI

public enum GameNetAPI {
    case login(data: LoginRequest)
    case refreshToken(data: RefreshTokenRequest)
    case dashboard
    case platforms
    case platform(id: String)
    case savePlatform(id: String?, data: PlatformRequest)

    case lists
    case finishedByYearList(id: String)
    case boughtByYearList(id: String)
    case list(id: String)
    case saveList(id: String?, data: ListGameRequest)

    case games(search: String?, page: Int?, pageSize: Int?)
    case game(id: String)
    case saveGame(data: GameEditRequest)
    case saveUserGame(data: UserGameEditRequest)
    case gameplays(id: String)
    case gameplaysByYear(year: Int, month: Int? = nil)
    case saveGameplaySession(data: GameplaySessionRequest)
    case finishGame(userGameId: String)
    case dropGameplay(userGameId: String)
    
    case serverDriven(slug: String)

    // MARK: Internal

    var baseURL: String {
        switch self {
        default:
            return APIConstants.apiPath
        }
    }

    var path: String {
        switch self {
        case .login:
            return "\(APIConstants.userResource)/login"
        case .refreshToken:
            return "\(APIConstants.userResource)/refresh"
        case .dashboard:
            return APIConstants.dashboardResource
        case .platforms:
            return APIConstants.platformResource
        case let .platform(id):
            return "\(APIConstants.platformResource)/\(id)"
        case let .savePlatform(id, _):
            if let id = id {
                return "\(APIConstants.platformResource)/\(id)"
            }

            return "\(APIConstants.platformResource)/"

        case .lists:
            return APIConstants.listResource
        case let .finishedByYearList(id):
            return "\(APIConstants.listResource)/FinishedByYear/\(id)"
        case let .boughtByYearList(id):
            return "\(APIConstants.listResource)/BoughtByYear/\(id)"
        case let .list(id):
            return "\(APIConstants.listResource)/\(id)"
        case let .saveList(id, _):
            if let id = id {
                return "\(APIConstants.listResource)/\(id)"
            }

            return APIConstants.listResource

        case let .games(search, page, pageSize):
            var resultUrl = "\(APIConstants.gameResource)?"

            if let search = search {
                resultUrl = "\(resultUrl)search=\(search)&"
            }

            if let page = page {
                resultUrl = "\(resultUrl)page=\(page)&"
            }

            if let pageSize = pageSize {
                resultUrl = "\(resultUrl)pageSize=\(pageSize)&"
            }

            return resultUrl
        case let .game(id):
            return "\(APIConstants.gameResource)/\(id)"
        case .saveGame:
            return "game"
        case .saveUserGame:
            return APIConstants.gameResource
        case let .gameplays(id):
            return "\(APIConstants.gameplaySessionResource)?userGameId=\(id)"
        case let .gameplaysByYear(year, month):
            if let monthValue = month {
                return "\(APIConstants.gameplaySessionResource)/sessionby/\(year)/\(monthValue)"
            } else {
                return "\(APIConstants.gameplaySessionResource)/sessionby/\(year)"
            }
        case let .saveGameplaySession(request):
            if request.finish != nil {
                return "\(APIConstants.gameplaySessionResource)?userGameId=\(request.userGameId)"
            }

            return APIConstants.gameplaySessionResource
        case let .finishGame(userGameId):
            return "\(APIConstants.gameResource)/finish-gameplay/\(userGameId)"
        case let .dropGameplay(userGameId):
            return "\(APIConstants.gameResource)/drop-gameplay/\(userGameId)"
        case let .serverDriven(slug):
            return "\(APIConstants.serverDrivenResource)/\(slug)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .dashboard,
             .platforms,
             .platform,

             .lists,
             .finishedByYearList,
             .boughtByYearList,
             .list,

             .games,
             .game,
             .gameplays,
             .gameplaysByYear,
             .serverDriven:
            return .get
        case .login,
             .refreshToken:
            return .post
        case let .savePlatform(id, _):
            if id != nil {
                return .put
            }

            return .post
        case let .saveList(id, _):
            if id != nil {
                return .put
            }

            return .post
        case .saveGame,
             .saveUserGame:
            return .post
        case let .saveGameplaySession(request):
            if request.finish != nil {
                return .put
            }
                
            return .post
        case .finishGame,
             .dropGameplay:
            return .put
        }
    }

    var parameterEncoder: ParameterEncoder {
        switch method {
        case .get: return URLEncodedFormParameterEncoder()
        default:
            let encoder = JSONParameterEncoder()
            encoder.encoder.dateEncodingStrategy = .iso8601
            return encoder
        }
    }

    var isRefreshToken: Bool {
        switch self {
        case .refreshToken:
            return true
        default:
            return false
        }
    }

    func encodeParameters(into request: URLRequest) throws -> URLRequest {
        switch self {
        case let .login(parameters):
            return try parameterEncoder.encode(parameters, into: request)
        case let .saveList(_, model):
            return try parameterEncoder.encode(model, into: request)
        case let .savePlatform(_, model):
            return try parameterEncoder.encode(model, into: request)
        case let .saveGame(model):
            return try parameterEncoder.encode(model, into: request)
        case let .saveUserGame(model):
            return try parameterEncoder.encode(model, into: request)
        case let .refreshToken(parameters):
            return try parameterEncoder.encode(parameters, into: request)
        case let .saveGameplaySession(parameters):
            return try parameterEncoder.encode(parameters, into: request)
        case .dashboard,
             .platforms,
             .platform,

             .lists,
             .finishedByYearList,
             .boughtByYearList,
             .list,

             .games,
             .game,
             .gameplays,
             .gameplaysByYear,
             .finishGame,
             .dropGameplay,
            
             .serverDriven:
            return request
        }
    }

}

// MARK: URLRequestConvertible

extension GameNetAPI: URLRequestConvertible {
    public func asURLRequest() throws -> URLRequest {
        let resultUrl = "\(baseURL)/\(path)"

        let url = try resultUrl.asURL()
        var request = URLRequest(url: url)
        request.method = method

        return try encodeParameters(into: request)
    }
}
