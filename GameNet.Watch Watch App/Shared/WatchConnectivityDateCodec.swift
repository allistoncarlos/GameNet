//
//  WatchConnectivityDateCodec.swift
//  GameNet.Watch Watch App
//
//  Created by Alliston Aleixo on 23/05/26.
//

import Foundation

enum WatchConnectivityDateCodec {
    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let habitDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()

    static func date(fromISO iso: String) -> Date? {
        if let date = isoFormatter.date(from: iso) {
            return date
        }
        return ISO8601DateFormatter().date(from: iso)
    }

    static func displayString(forHabitDayISO iso: String) -> String {
        guard let date = habitDayFormatter.date(from: iso) else { return iso }
        return displayFormatter.string(from: date)
    }

    static func habitDayOptions() -> [String] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0 ... 2).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else {
                return nil
            }
            return habitDayFormatter.string(from: date)
        }
    }
}
