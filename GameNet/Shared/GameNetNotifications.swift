//
//  GameNetNotifications.swift
//  GameNet
//

import Foundation

public extension Notification.Name {
    /// Publicado quando o widget/Island altera uma sessão — o app refresca o dashboard.
    static let gameplaySessionDidChangeFromWidget = Notification.Name(
        "com.alliston.GameNetApp.gameplaySessionDidChangeFromWidget"
    )
}
