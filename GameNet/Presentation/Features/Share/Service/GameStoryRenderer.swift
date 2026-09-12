//
//  GameStoryRenderer.swift
//  GameNet
//
//  Exporta a arte do story para imagem (1080x1920).
//

import SwiftUI

#if os(iOS)
import UIKit

enum GameStoryRenderer {

    /// Renderiza a arte do story em escala 1:1 (1080x1920 px).
    @MainActor
    static func render(
        content: GameStoryContent,
        template: InstagramStoryTemplate,
        cover: Image?,
        accent: Color,
        elapsedText: String?
    ) -> UIImage? {
        let canvas = GameStoryCanvasView(
            content: content,
            template: template,
            cover: cover,
            accent: accent,
            elapsedText: elapsedText
        )

        let renderer = ImageRenderer(content: canvas)
        renderer.scale = 1
        renderer.isOpaque = true
        renderer.proposedSize = ProposedViewSize(GameStoryCanvasView.size)

        return renderer.uiImage
    }
}
#endif
