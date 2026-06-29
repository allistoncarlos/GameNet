//
//  WatchConnectivityDateCodec.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/05/26.
//

import Foundation

// MARK: - WatchConnectivityDateCodec

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

    static func isoString(from date: Date) -> String {
        isoFormatter.string(from: date)
    }

    static func date(fromISO iso: String) -> Date? {
        if let date = isoFormatter.date(from: iso) {
            return date
        }

        let fallback = ISO8601DateFormatter()
        return fallback.date(from: iso)
    }

    static func habitDayISO(from date: Date) -> String {
        habitDayFormatter.string(from: date)
    }

    static func displayString(forHabitDayISO iso: String) -> String {
        guard let date = habitDayFormatter.date(from: iso) else { return iso }
        return displayFormatter.string(from: date)
    }

    static func startDate(forHabitDayISO iso: String) -> Date? {
        guard let day = habitDayFormatter.date(from: iso) else { return nil }

        let calendar = Calendar.current
        let now = Date()
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: now)

        return calendar.date(
            bySettingHour: timeComponents.hour ?? 12,
            minute: timeComponents.minute ?? 0,
            second: timeComponents.second ?? 0,
            of: day
        )
    }

    static func habitDayOptions() -> [String] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0 ... 2).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else {
                return nil
            }
            return habitDayISO(from: date)
        }
    }

    static func displayLabel(forHabitDayISO iso: String, index: Int) -> String {
        switch index {
        case 0:
            return "Hoje"
        case 1:
            return "Ontem"
        default:
            return displayString(forHabitDayISO: iso)
        }
    }
}
