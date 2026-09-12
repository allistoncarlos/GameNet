//
//  GameStoryShareModifier.swift
//  GameNet
//
//  Apresenta a folha de compartilhamento do story.
//

import SwiftUI

extension View {
    /// Abre a pré-visualização do story quando `content` deixa de ser `nil`.
    ///
    /// Fora do iOS o modificador não faz nada — o compositor de stories do
    /// Instagram só existe no iPhone.
    @ViewBuilder
    func gameStoryShareSheet(_ content: Binding<GameStoryContent?>) -> some View {
        #if os(iOS)
        sheet(item: content) { storyContent in
            ShareGameStorySheet(content: storyContent)
        }
        #else
        self
        #endif
    }
}

// MARK: - ShareStoryLabel

/// Ícone padrão das ações de compartilhar story.
struct ShareStoryLabel: View {
    var size: CGFloat = 34

    var body: some View {
        Image(systemName: "square.and.arrow.up")
            .frame(width: size, height: size)
    }
}
