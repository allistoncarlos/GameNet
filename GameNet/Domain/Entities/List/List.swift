//
//  List.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation

public struct List: Identifiable, Equatable, Hashable {

    // MARK: Lifecycle

    public init(
        id: String?,
        name: String
    ) {
        self.id = id
        self.name = name
    }

    // MARK: Public

    public var id: String?
    public var name: String

    public func toRequest() -> ListRequest {
        return ListRequest(id: id, name: name)
    }
}
