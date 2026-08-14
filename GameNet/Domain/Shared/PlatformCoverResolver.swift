//
//  PlatformCoverResolver.swift
//  GameNet
//

import Foundation

struct ParsedPlatformName: Equatable {
    let original: String
    let base: String
    let qualifier: String?
    let coverSearchName: String
    let identity: String
}

enum PlatformCoverResolver {
    static let ignoredPhrases = [
        "virtual console",
        "3d classics",
        "pc port",
        "emulador",
        "emulator",
        "youtube",
        "steam",
        "epic",
        "r36s",
        "yt"
    ]

    static func parse(_ name: String) -> ParsedPlatformName {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        var base = trimmed
        var qualifier: String?

        if let open = trimmed.lastIndex(of: "("),
           let close = trimmed.lastIndex(of: ")"),
           open < close {
            let inside = String(trimmed[trimmed.index(after: open)..<close])
            base = String(trimmed[..<open]).trimmingCharacters(in: .whitespacesAndNewlines)
            let normalizedQualifier = stripIgnored(normalize(inside))
            qualifier = normalizedQualifier.isEmpty ? nil : inside.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let coverSearchName: String
        if let qualifier {
            coverSearchName = qualifier
        } else {
            let strippedBase = stripIgnored(normalize(base))
            coverSearchName = strippedBase.isEmpty ? base : displayFromNormalized(strippedBase, fallback: base)
        }

        return ParsedPlatformName(
            original: trimmed,
            base: base,
            qualifier: qualifier,
            coverSearchName: coverSearchName,
            identity: stripIgnored(normalize(trimmed))
        )
    }

    struct CatalogSearch: Equatable {
        let gameName: String
        let platformHint: String?
    }

    static func catalogSearch(
        from query: String,
        platforms: [(id: Int, name: String, alias: String?)] = []
    ) -> CatalogSearch {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let originalTokens = trimmed.split(whereSeparator: \.isWhitespace).map(String.init)
        guard originalTokens.count >= 2 else {
            return CatalogSearch(gameName: trimmed, platformHint: nil)
        }

        let maxSuffix = min(4, originalTokens.count - 1)
        for length in stride(from: maxSuffix, through: 1, by: -1) {
            let suffix = originalTokens.suffix(length).joined(separator: " ")
            if looksLikePlatform(suffix, platforms: platforms) {
                let gameName = originalTokens.dropLast(length).joined(separator: " ")
                return CatalogSearch(gameName: gameName, platformHint: suffix)
            }
        }

        return CatalogSearch(gameName: trimmed, platformHint: nil)
    }

    static func candidates(matching query: String, in platforms: [Platform]) -> [Platform] {
        let needle = stripIgnored(normalize(query))
        guard !needle.isEmpty else { return [] }

        let grouped = Dictionary(grouping: platforms) { parse($0.name).identity }

        let representatives: [Platform] = grouped.values.compactMap { group in
            group.first { parse($0.name).qualifier == nil } ?? group.first
        }

        let matched = representatives.filter { platform in
            let parsed = parse(platform.name)
            return matches(needle: needle, parsed: parsed)
        }

        return matched.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    static func normalize(_ string: String) -> String {
        let folded = string
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: "gameboy", with: "game boy", options: .caseInsensitive)

        let scalars = folded.unicodeScalars.map { scalar -> Character in
            CharacterSet.alphanumerics.contains(scalar) ? Character(scalar) : " "
        }

        return String(scalars)
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func stripIgnored(_ normalized: String) -> String {
        var result = " \(normalized) "
        for phrase in ignoredPhrases.sorted(by: { $0.count > $1.count }) {
            result = result.replacingOccurrences(of: " \(phrase) ", with: " ")
        }

        return result
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }

    static func matchTheGamesDBPlatform(
        coverSearchName: String,
        platforms: [(id: Int, name: String, alias: String?)]
    ) -> Int? {
        let needle = stripIgnored(normalize(coverSearchName))
        guard !needle.isEmpty else { return nil }

        let expandedNeedles = expandedPlatformNeedles(for: needle)

        if let exact = platforms.first(where: { platform in
            let name = stripIgnored(normalize(platform.name))
            let alias = stripIgnored(normalize(platform.alias ?? ""))
            return expandedNeedles.contains(name) || (!alias.isEmpty && expandedNeedles.contains(alias))
        }) {
            return exact.id
        }

        return platforms.first(where: { platform in
            let name = stripIgnored(normalize(platform.name))
            let alias = stripIgnored(normalize(platform.alias ?? ""))
            return expandedNeedles.contains { candidate in
                name == candidate
                    || alias == candidate
                    || tokens(in: name) == tokens(in: candidate)
                    || containsAllTokens(haystack: name, needle: candidate)
            }
        })?.id
    }

    private static let platformAliases: [String: [String]] = [
        "nes": ["nintendo entertainment system", "nes"],
        "snes": ["super nintendo", "super nintendo entertainment system", "snes"],
        "n64": ["nintendo 64", "n64"],
        "mega drive": ["sega mega drive", "sega genesis", "mega drive", "genesis"],
        "master system": ["sega master system", "master system"],
        "game boy advance": ["game boy advance", "gba"],
        "game boy color": ["game boy color", "gbc"],
        "nintendo switch": ["nintendo switch", "switch"],
        "nintendo 3ds": ["nintendo 3ds", "3ds"],
        "nintendo ds": ["nintendo ds", "nds"],
        "nintendo gamecube": ["nintendo gamecube", "gamecube", "game cube"],
        "wii u": ["wii u", "wiiu", "nintendo wii u"],
        "wii": ["wii", "nintendo wii"]
    ]

    private static func looksLikePlatform(
        _ value: String,
        platforms: [(id: Int, name: String, alias: String?)]
    ) -> Bool {
        if matchTheGamesDBPlatform(coverSearchName: value, platforms: platforms) != nil {
            return true
        }

        let needle = stripIgnored(normalize(value))
        guard !needle.isEmpty else { return false }

        return expandedPlatformNeedles(for: needle).count > 1 || platformAliases[needle] != nil
    }

    private static func expandedPlatformNeedles(for needle: String) -> Set<String> {
        var expanded: Set<String> = [needle]

        for (key, values) in platformAliases {
            let normalizedValues = values.map { stripIgnored(normalize($0)) }
            if key == needle || normalizedValues.contains(needle) {
                expanded.insert(key)
                expanded.formUnion(normalizedValues)
            }
        }

        return Set(expanded.map { stripIgnored(normalize($0)) })
    }

    private static func matches(needle: String, parsed: ParsedPlatformName) -> Bool {
        let fields = [
            parsed.identity,
            stripIgnored(normalize(parsed.base)),
            stripIgnored(normalize(parsed.coverSearchName)),
            parsed.qualifier.map { stripIgnored(normalize($0)) }
        ].compactMap { $0 }.filter { !$0.isEmpty }

        return fields.contains { field in
            tokens(in: field) == tokens(in: needle)
                || containsAllTokens(haystack: field, needle: needle)
                || containsAllTokens(haystack: needle, needle: field)
        }
    }

    private static func tokens(in string: String) -> [String] {
        string.split(separator: " ").map(String.init)
    }

    private static func containsAllTokens(haystack: String, needle: String) -> Bool {
        let haystackTokens = tokens(in: haystack)
        let needleTokens = tokens(in: needle)
        guard !needleTokens.isEmpty else { return false }
        return needleTokens.allSatisfy { haystackTokens.contains($0) }
    }

    private static func displayFromNormalized(_ normalized: String, fallback: String) -> String {
        fallback.isEmpty ? normalized : fallback
    }
}
