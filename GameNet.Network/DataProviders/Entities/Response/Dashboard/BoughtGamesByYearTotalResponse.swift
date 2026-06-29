//
//  BoughtGamesByYearTotalResponse.swift
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation

public struct BoughtGamesByYearTotalResponse: Codable {
    public var year: Int
    public var total: Decimal
    public var quantity: Int

    enum CodingKeys: String, CodingKey {
        case year
        case total
        case quantity
    }
    
    public func toBoughtGamesByYearTotal() -> BoughtGamesByYearTotal {
        return BoughtGamesByYearTotal(year: self.year,
                                      total: self.total,
                                      quantity: self.quantity)
    }
}
