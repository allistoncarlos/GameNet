//
//  BoughtGamesByYearTotal.swift  
//
//  Created by Alliston Aleixo on 19/05/22.
//

import Foundation
import SwiftData

@Model
public class BoughtGamesByYearTotal: Equatable, Hashable {
    public var year: Int
    public var total: Decimal
    public var quantity: Int

    public init(year: Int,
         total: Decimal,
         quantity: Int
    ) {
        self.year = year
        self.total = total
        self.quantity = quantity
    }
}
