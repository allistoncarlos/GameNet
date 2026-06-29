//
//  APIResult.swift
//
//  Created by Alliston Aleixo on 18/05/22.
//

import Foundation

public struct APIResult<T: Codable>: Codable {
    public var ok: Bool
    public var errors: [String]
    public var data: T

    enum CodingKeys: String, CodingKey {
        case ok
        case errors
        case data
    }
}
