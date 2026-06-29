//
//  ListItem.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation
import SwiftData

@Model
public class ListItem: Identifiable, Equatable, Hashable {

    // MARK: Lifecycle

    public init(
        id: String?,
        name: String,
        platform: String?,
        userGameId: String?,
        year: Int?,
        boughtDate: Date?,
        value: Decimal?,
        start: Date?,
        finish: Date?,
        cover: String?,
        order: Int?,
        comment: String?
    ) {
        self.id = id
        self.name = name
        self.platform = platform
        self.userGameId = userGameId
        self.year = year
        self.boughtDate = boughtDate
        self.value = value
        self.start = start
        self.finish = finish
        self.cover = cover
        self.order = order
        self.comment = comment
    }

    // MARK: Public

    public var id: String?
    public var name: String
    public var platform: String?
    public var userGameId: String?
    public var year: Int?
    public var boughtDate: Date?
    public var value: Decimal?
    public var start: Date?
    public var finish: Date?
    public var cover: String?
    public var order: Int?
    public var comment: String?

}
