//
//  GameplayLiveActivityManager+macOS.swift
//  GameNet
//

#if os(macOS)
import Foundation

@MainActor
enum GameplayLiveActivityManager {
    static func sync(with games: [WidgetSharedPlayingGame]) async {}
    static func syncFromStore() async {}
    static func startOrUpdate(
        userGameId: String,
        gameName: String,
        platform: String,
        coverURL: String,
        sessionStart: Date
    ) async {}
    static func end(userGameId: String?) async {}
    static func endAll() async {}
}
#endif
