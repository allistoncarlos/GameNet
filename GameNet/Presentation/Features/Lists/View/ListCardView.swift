//
//  ListCardView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 14/08/26.
//

import CachedAsyncImage
import SwiftUI

struct ListCardView: View {
    let model: ListCardModel

    private let cardHeight: CGFloat = 96
    private let accentBarWidth: CGFloat = 5
    private let cornerRadius: CGFloat = 16

    var body: some View {
        HStack(spacing: 0) {
            Color.main
                .frame(width: accentBarWidth)

            ZStack(alignment: .leading) {
                coverStrip

                titleFade

                GeometryReader { geometry in
                    Text(model.name)
                        .font(.listCardTitle)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .minimumScaleFactor(0.85)
                        .shadow(color: .black.opacity(0.45), radius: 4, y: 1)
                        .padding(.leading, 14)
                        .frame(width: geometry.size.width * 0.58, alignment: .leading)
                        .frame(maxHeight: .infinity, alignment: .center)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .background(Color.primaryCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: .black.opacity(0.22), radius: 8, y: 3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(model.name)
        .accessibilityValue(accessibilityValue)
        .accessibilityAddTraits(.isButton)
    }

    @ViewBuilder
    private var coverStrip: some View {
        if model.previewGames.isEmpty {
            Color.primaryCardBackground
        } else {
            HStack(spacing: 0) {
                ForEach(Array(model.previewGames.enumerated()), id: \.offset) { index, game in
                    coverSlice(
                        coverURL: game.cover,
                        showsOverflow: shouldShowOverflow(at: index)
                    )
                }
            }
        }
    }

    private var titleFade: some View {
        LinearGradient(
            stops: [
                .init(color: Color.primaryCardBackground, location: 0),
                .init(color: Color.primaryCardBackground.opacity(0.92), location: 0.22),
                .init(color: Color.primaryCardBackground.opacity(0.62), location: 0.46),
                .init(color: Color.primaryCardBackground.opacity(0.22), location: 0.7),
                .init(color: .clear, location: 1)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .allowsHitTesting(false)
    }

    private func coverSlice(coverURL: String?, showsOverflow: Bool) -> some View {
        GeometryReader { geometry in
            CachedAsyncImage(
                url: URL(string: coverURL ?? "")
            ) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .scaleEffect(1.14)
                        .blur(radius: showsOverflow ? 8 : 0)
                default:
                    Color.primaryCardBackground.opacity(0.65)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
            .overlay {
                if showsOverflow, let overflowCount = model.overflowCount {
                    ZStack {
                        Color.black.opacity(0.48)
                        Text("+\(overflowCount)")
                            .font(.listCardOverflow)
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.6), radius: 2, y: 1)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func shouldShowOverflow(at index: Int) -> Bool {
        index == model.previewGames.count - 1 && model.overflowCount != nil
    }

    private var accessibilityValue: String {
        let count = model.games.count
        if count == 0 {
            return "Lista vazia"
        }
        return count == 1 ? "1 jogo" : "\(count) jogos"
    }
}
