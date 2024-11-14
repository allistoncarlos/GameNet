//
//  Date+Extensions.swift
//  GameNet
//
//  Created by Alliston Aleixo on 22/08/22.
//

import Foundation

extension Date {
    func toFormattedString(dateFormat: String? = nil) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Locale.current.identifier)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        if let dateFormat = dateFormat {
            dateFormatter.dateFormat = dateFormat
        } else {
            dateFormatter.dateStyle = .short
        }

        return dateFormatter.string(from: self)
    }

    func dateOnly() -> Date {
        let formattedDate = formatted(date: .numeric, time: .omitted)

        let expectedFormat = Date.FormatStyle()
            .month().day().year()

        return try! Date(formattedDate, strategy: expectedFormat)
    }
    
    static func timeZoneDate() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: Date()))
        return Date(timeInterval: seconds, since: Date())
    }

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}

extension String {
    func toDate() -> Date? {
        let dateFormatter = ISO8601DateFormatter()

        return dateFormatter.date(from: self)
    }
}
