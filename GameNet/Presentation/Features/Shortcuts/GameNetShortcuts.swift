//
//  GameNetShortcuts.swift
//  GameNet
//

#if os(iOS)
import AppIntents
import Foundation

struct GameNetShortcuts: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .navy

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddGameToListIntent(),
            phrases: [
                "Add to \(\.$list) with \(.applicationName)",
                "Add to \(\.$list) in \(.applicationName)",
                "Add \(\.$game) with \(.applicationName)"
            ],
            shortTitle: "Add to List",
            systemImageName: "text.badge.plus"
        )
        AppShortcut(
            intent: CreateGameIntent(),
            phrases: [
                "Create game on \(\.$platform) with \(.applicationName)",
                "Add game on \(\.$platform) with \(.applicationName)"
            ],
            shortTitle: "Create Game",
            systemImageName: "plus.square.on.square"
        )
    }
}
#endif
