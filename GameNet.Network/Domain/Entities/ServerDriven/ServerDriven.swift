//
//  ServerDriven.swift
//  GameNet.Network
//
//  Created by Alliston Aleixo on 23/11/24.
//

import Foundation
import SwiftData

@Model
public class ServerDriven: Identifiable, Equatable, Hashable {

    // MARK: Lifecycle

    public init(id: String?, slug: String, json: String) {
        self.id = id
        self.slug = slug
        self.json = json
    }

    // MARK: Public

    public var id: String?
    public var slug: String
    public var json: String
}
