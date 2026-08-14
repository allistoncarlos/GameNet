//
//  Slug.swift
//  GameNet
//

import Foundation

enum Slug {
    /// Mirrors Nest/API `generateSlug` used for game covers and platform illustrations.
    static func generate(_ text: String) -> String {
        let lowered = text.lowercased()
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789 ")
        let filtered = lowered.unicodeScalars.filter { allowed.contains($0) }

        let collapsed = String(String.UnicodeScalarView(filtered))
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)

        let limited = String(collapsed.prefix(45))
        return limited.replacingOccurrences(of: " ", with: "-")
    }
}
