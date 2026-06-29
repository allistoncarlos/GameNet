//
//  Platform.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation
import SwiftData

@Model
public class Platform: Identifiable, Equatable, Hashable {
    // MARK: Lifecycle
    public init(id: String?, name: String) {
        self.id = id
        self.name = name
    }

    // MARK: Public
    public var id: String?
    public var name: String

    public func toRequest() -> PlatformRequest {
        return PlatformRequest(id: id, name: name)
    }
}
