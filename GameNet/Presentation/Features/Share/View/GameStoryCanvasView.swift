//
//  GameStoryCanvasView.swift
//  GameNet
//
//  Arte do story em 1080x1920, renderizada por `GameStoryRenderer`.
//

import SwiftUI

/// Arte do story desenhada no tamanho nativo do Instagram (1080x1920).
///
/// Só usa formas, gradientes, textos e imagens — nada de `blur` ou material,
/// que o `ImageRenderer` não exporta corretamente.
struct GameStoryCanvasView: View {

    // MARK: Internal

    static let size = CGSize(width: 1080, height: 1920)

    let content: GameStoryContent
    let template: InstagramStoryTemplate
    let cover: Image?
    let accent: Color
    /// Tempo decorrido congelado no momento da renderização.
    let elapsedText: String?

    var body: some View {
        Group {
            switch template {
            case .poster:
                posterLayout
            case .card:
                cardLayout
            case .fullBleed:
                fullBleedLayout
            }
        }
        .frame(width: Self.size.width, height: Self.size.height)
        .background(Color.black)
        .clipped()
        .environment(\.colorScheme, .dark)
    }

    // MARK: Private

    private var badgeTitle: String {
        content.isPlayingNow ? "JOGANDO AGORA" : "NA MINHA BIBLIOTECA"
    }
}

// MARK: - Layouts

private extension GameStoryCanvasView {
    var posterLayout: some View {
        ZStack {
            LinearGradient(
                colors: [
                    accent.opacity(0.95),
                    accent.opacity(0.45),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 0) {
                badge
                    .padding(.bottom, 64)

                coverArtwork(width: 620, cornerRadius: 36)
                    .shadow(color: .black.opacity(0.55), radius: 60, y: 28)

                titleBlock(alignment: .center, nameSize: 84, platformSize: 44)
                    .padding(.top, 76)
                    .padding(.horizontal, 90)

                timeChips
                    .padding(.top, 64)

                Spacer(minLength: 0)

                footer
            }
            .padding(.top, 200)
            .padding(.bottom, 110)
        }
    }

    var cardLayout: some View {
        ZStack {
            Color.black

            RadialGradient(
                colors: [accent.opacity(0.8), accent.opacity(0.1), .clear],
                center: .top,
                startRadius: 60,
                endRadius: 1200
            )

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                VStack(spacing: 44) {
                    badge

                    coverArtwork(width: 500, cornerRadius: 28)
                        .shadow(color: .black.opacity(0.5), radius: 40, y: 20)

                    titleBlock(alignment: .center, nameSize: 70, platformSize: 40)

                    Rectangle()
                        .fill(Color.white.opacity(0.16))
                        .frame(height: 2)

                    timeChips
                }
                .padding(.vertical, 64)
                .padding(.horizontal, 56)
                .background(
                    RoundedRectangle(cornerRadius: 56, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 56, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.18), lineWidth: 3)
                )
                .padding(.horizontal, 90)

                Spacer(minLength: 0)

                footer
                    .padding(.bottom, 110)
            }
        }
    }

    var fullBleedLayout: some View {
        ZStack(alignment: .bottom) {
            coverBackdrop

            LinearGradient(
                colors: [
                    .black.opacity(0.65),
                    .black.opacity(0.05),
                    .black.opacity(0.6),
                    .black.opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 32) {
                badge

                titleBlock(alignment: .leading, nameSize: 92, platformSize: 46)

                timeChips
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 90)
            .padding(.bottom, 150)
        }
        .overlay(alignment: .top) {
            footer
                .padding(.top, 120)
        }
    }
}

// MARK: - Blocos

private extension GameStoryCanvasView {
    @ViewBuilder
    var coverBackdrop: some View {
        if let cover {
            cover
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: Self.size.width, height: Self.size.height)
        } else {
            LinearGradient(
                colors: [accent.opacity(0.9), .black],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    @ViewBuilder
    func coverArtwork(width: CGFloat, cornerRadius: CGFloat) -> some View {
        Group {
            if let cover {
                cover
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                LinearGradient(
                    colors: [accent.opacity(0.7), .black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .frame(width: width, height: width * 3 / 2)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 3)
        )
    }

    var badge: some View {
        HStack(spacing: 18) {
            Circle()
                .fill(content.isPlayingNow ? Color.white : Color.white.opacity(0.7))
                .frame(width: 20, height: 20)

            Text(badgeTitle)
                .font(.custom("AvenirNext-DemiBold", size: 34))
                .kerning(4)
        }
        .foregroundStyle(.white)
        .padding(.vertical, 22)
        .padding(.horizontal, 42)
        .background(Capsule().fill(Color.white.opacity(0.18)))
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.35), lineWidth: 2))
    }

    func titleBlock(
        alignment: HorizontalAlignment,
        nameSize: CGFloat,
        platformSize: CGFloat
    ) -> some View {
        VStack(alignment: alignment, spacing: 18) {
            Text(content.gameName)
                .font(.custom("AvenirNext-DemiBold", size: nameSize))
                .lineLimit(3)
                .minimumScaleFactor(0.55)
                .multilineTextAlignment(alignment == .leading ? .leading : .center)

            Text(content.platform)
                .font(.custom("AvenirNext-Regular", size: platformSize))
                .opacity(0.85)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .center)
    }

    @ViewBuilder
    var timeChips: some View {
        let total = content.totalGameplayTime?.trimmingCharacters(in: .whitespaces) ?? ""

        HStack(spacing: 24) {
            if let elapsedText {
                timeChip(icon: "stopwatch.fill", label: "Nesta sessão", value: elapsedText)
            }

            if !total.isEmpty {
                timeChip(icon: "clock.fill", label: "Tempo total", value: total)
            }
        }
    }

    func timeChip(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 30, weight: .semibold))

                Text(label)
                    .font(.custom("AvenirNext-Regular", size: 30))
            }
            .opacity(0.8)

            Text(value)
                .font(.custom("AvenirNext-DemiBold", size: 56))
                .monospacedDigit()
        }
        .foregroundStyle(.white)
        .padding(.vertical, 26)
        .padding(.horizontal, 40)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.14))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.white.opacity(0.22), lineWidth: 2)
        )
    }

    var footer: some View {
        HStack(spacing: 16) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 34, weight: .semibold))

            Text("GameNet")
                .font(.custom("AvenirNext-DemiBold", size: 40))
                .kerning(2)
        }
        .foregroundStyle(.white.opacity(0.75))
    }
}
