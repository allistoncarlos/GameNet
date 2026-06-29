//
//  FinishedGameByYearTotal.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation
import SwiftData

@Model
public class FinishedGameByYearTotal: Equatable, Hashable {
    public var year: Int
    public var total: Int

    public init(year: Int, total: Int) {
        self.year = year
        self.total = total
    }
}
