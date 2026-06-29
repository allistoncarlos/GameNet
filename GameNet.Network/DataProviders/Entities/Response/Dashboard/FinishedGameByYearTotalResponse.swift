//
//  FinishedGameByYearTotalResponse.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation

public struct FinishedGameByYearTotalResponse: Codable {
    public var year: Int
    public var total: Int

    enum CodingKeys: String, CodingKey {
        case year
        case total
    }
    
    public func toFinishedGameByYearTotal() -> FinishedGameByYearTotal {
        return FinishedGameByYearTotal(year: self.year, total: self.total)
    }
}
