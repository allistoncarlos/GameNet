//
//  LoginRequestModel.swift
//
//  Created by Alliston Aleixo on 18/05/22.
//

import Foundation

public struct LoginRequest: Codable {
    public var username: String
    public var password: String

    enum CodingKeys: String, CodingKey {
        case username
        case password
    }
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}
