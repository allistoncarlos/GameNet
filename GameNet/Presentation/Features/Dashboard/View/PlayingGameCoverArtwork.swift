//
//  PlayingGameCoverArtwork.swift
//  GameNet
//

import CachedAsyncImage
import SwiftUI

struct PlayingGameCoverArtwork: View {
    let coverURL: String
    var cornerRadius: CGFloat = 12
    var contentMode: ContentMode = .fill
    var transitionId: String? = nil

    var body: some View {
        Color.clear
            .aspectRatio(2 / 3, contentMode: .fit)
            .overlay {
                CachedAsyncImage(url: URL(string: coverURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: contentMode)
                    default:
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.secondary.opacity(0.2))
                            .redacted(reason: .placeholder)
                    }
                }
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .gameCoverTransitionSource(id: transitionId)
    }
}
