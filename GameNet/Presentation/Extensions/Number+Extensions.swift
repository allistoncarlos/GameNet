//
//  Number+Extensions.swift
//  GameNet
//
//  Created by Alliston Aleixo on 22/08/22.
//

import Foundation

extension Double {
    func toCurrencyString() -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency

        return numberFormatter.string(from: NSNumber(value: self))
    }
}

extension Int {
    func toLeadingZerosString(decimalPlaces: Int) -> String {
        return String(format: "%0\(decimalPlaces)d", self)
    }
}

extension Decimal {
    func toLeadingZerosString(decimalPlaces: Int) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = decimalPlaces

        return numberFormatter.string(from: NSDecimalNumber(decimal: self))
    }
}
