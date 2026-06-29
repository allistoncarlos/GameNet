//
//  ListRequest.swift
//
//  Created by Alliston Aleixo on 18/05/22.
//

import Foundation

public struct ListRequest: Identifiable, Encodable {
    public var id: String?
    var name: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}
