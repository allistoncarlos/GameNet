//
//  InstagramStorySharer.swift
//  GameNet
//
//  Envia a arte para o compositor de stories do Instagram.
//

import SwiftUI

#if os(iOS)
import UIKit

enum InstagramStorySharer {

    // MARK: Internal

    enum Failure: Error {
        /// Instagram não instalado (ou `instagram-stories` fora do LSApplicationQueriesSchemes).
        case instagramUnavailable
        case invalidImage
    }

    /// `true` quando o app consegue abrir o compositor de stories.
    @MainActor
    static var isAvailable: Bool {
        guard let url = URL(string: "\(scheme)://share") else { return false }

        return UIApplication.shared.canOpenURL(url)
    }

    /// Cola a arte no pasteboard do Instagram e abre o compositor de stories.
    ///
    /// O Instagram lê os itens do `UIPasteboard` logo após o `open(_:)`; por isso
    /// o pasteboard expira em 5 minutos e não em uma sessão infinita.
    @MainActor
    static func share(image: UIImage, background: Color) async throws {
        guard isAvailable else { throw Failure.instagramUnavailable }
        guard let data = image.pngData() else { throw Failure.invalidImage }

        let top = background.storyHexString(darkenedBy: 0.15)
        let bottom = background.storyHexString(darkenedBy: 0.7)

        let items: [String: Any] = [
            "com.instagram.sharedSticker.backgroundImage": data,
            "com.instagram.sharedSticker.backgroundTopColor": top,
            "com.instagram.sharedSticker.backgroundBottomColor": bottom
        ]

        UIPasteboard.general.setItems(
            [items],
            options: [.expirationDate: Date().addingTimeInterval(60 * 5)]
        )

        guard
            let url = URL(string: "\(scheme)://share?source_application=\(sourceApplication)")
        else {
            throw Failure.instagramUnavailable
        }

        _ = await UIApplication.shared.open(url)
    }

    // MARK: Private

    private static let scheme = "instagram-stories"

    /// Identificador exigido pelo Instagram: usa `INSTAGRAM_APP_ID` do Info.plist
    /// quando existir (Facebook App ID) e cai no bundle id do app.
    private static var sourceApplication: String {
        if let appId = Bundle.main.object(forInfoDictionaryKey: "INSTAGRAM_APP_ID") as? String,
           !appId.isEmpty,
           !appId.hasPrefix("$(") {
            return appId
        }

        return Bundle.main.bundleIdentifier ?? "com.alliston.GameNetApp"
    }
}

// MARK: - Cor de fundo

private extension Color {
    /// Hex `#RRGGBB` escurecido, usado no gradiente de fundo do story.
    func storyHexString(darkenedBy amount: CGFloat) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return "#000000"
        }

        let factor = max(0, 1 - amount)

        return String(
            format: "#%02X%02X%02X",
            Int((red * factor * 255).rounded()),
            Int((green * factor * 255).rounded()),
            Int((blue * factor * 255).rounded())
        )
    }
}
#endif
