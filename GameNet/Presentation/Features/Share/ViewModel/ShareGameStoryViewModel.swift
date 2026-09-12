//
//  ShareGameStoryViewModel.swift
//  GameNet
//

import SwiftUI

#if os(iOS)
import UIKit

/// Imagem pronta para o share sheet nativo (fallback quando não há Instagram).
struct StoryShareImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

@MainActor
final class ShareGameStoryViewModel: ObservableObject {

    // MARK: Lifecycle

    init(content: GameStoryContent) {
        self.content = content
    }

    // MARK: Internal

    let content: GameStoryContent

    @Published var template: InstagramStoryTemplate = .poster
    @Published var fallbackShare: StoryShareImage?
    @Published var errorMessage: String?
    @Published private(set) var cover: Image?
    @Published private(set) var accent: Color = .main
    @Published private(set) var isLoadingCover = true
    @Published private(set) var isSharing = false

    var isInstagramAvailable: Bool {
        InstagramStorySharer.isAvailable
    }

    /// Baixa a capa uma única vez e extrai a cor de destaque do story.
    func loadCover() async {
        guard cover == nil else { return }

        defer { isLoadingCover = false }

        guard
            let url = URL(string: content.coverURL),
            let (data, _) = try? await URLSession.shared.data(from: url),
            let image = UIImage(data: data)
        else {
            return
        }

        cover = Image(uiImage: image)
        accent = image.accentColor()
    }

    /// Renderiza a arte e abre o compositor de stories; cai no share sheet
    /// nativo quando o Instagram não está instalado.
    func shareOnInstagram() async {
        guard !isSharing else { return }

        isSharing = true
        defer { isSharing = false }

        guard let image = renderStory() else {
            errorMessage = "Não consegui gerar a imagem do story."
            return
        }

        do {
            try await InstagramStorySharer.share(image: image, background: accent)
        } catch InstagramStorySharer.Failure.instagramUnavailable {
            fallbackShare = StoryShareImage(image: image)
        } catch {
            errorMessage = "Não consegui abrir o Instagram."
        }
    }

    /// Share sheet nativo (salvar na galeria, enviar para outro app…).
    func shareElsewhere() {
        guard let image = renderStory() else {
            errorMessage = "Não consegui gerar a imagem do story."
            return
        }

        fallbackShare = StoryShareImage(image: image)
    }

    // MARK: Private

    private func renderStory() -> UIImage? {
        GameStoryRenderer.render(
            content: content,
            template: template,
            cover: cover,
            accent: accent,
            elapsedText: content.elapsedText()
        )
    }
}
#endif
