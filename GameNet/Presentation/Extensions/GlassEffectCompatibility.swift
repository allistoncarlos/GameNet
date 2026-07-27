//
//  GlassEffectCompatibility.swift
//  GameNet
//

import SwiftUI

struct GameNetGlassContainer<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder var content: () -> Content

    var body: some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: spacing, content: content)
        } else {
            content()
        }
        #elseif os(macOS)
        if #available(macOS 26.0, *) {
            GlassEffectContainer(spacing: spacing, content: content)
        } else {
            content()
        }
        #else
        content()
        #endif
    }
}

enum GameNetGlassStyle {
    case regular
    case tinted(Color, opacity: Double = 1.0)
}

enum GameNetGlassShape {
    case rect(cornerRadius: CGFloat)
    case capsule
    case circle
}

extension View {
    @ViewBuilder
    func gameNetGlassEffect(
        _ style: GameNetGlassStyle = .regular,
        in shape: GameNetGlassShape = .rect(cornerRadius: 12)
    ) -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            applyNativeGlass(style: style, shape: shape)
        } else {
            gameNetGlassFallback(style: style, shape: shape)
        }
        #elseif os(macOS)
        if #available(macOS 26.0, *) {
            applyNativeGlass(style: style, shape: shape)
        } else {
            gameNetGlassFallback(style: style, shape: shape)
        }
        #else
        gameNetGlassFallback(style: style, shape: shape)
        #endif
    }

    @ViewBuilder
    func gameNetGlassProminentButtonStyle(tint: Color = .main) -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            buttonStyle(.glassProminent)
                .tint(tint)
        } else {
            buttonStyle(.borderedProminent)
                .tint(tint)
        }
        #elseif os(macOS)
        if #available(macOS 26.0, *) {
            buttonStyle(.glassProminent)
                .tint(tint)
        } else {
            buttonStyle(.borderedProminent)
                .tint(tint)
        }
        #else
        buttonStyle(.borderedProminent)
            .tint(tint)
        #endif
    }

    @available(iOS 26.0, macOS 26.0, *)
    @ViewBuilder
    private func applyNativeGlass(style: GameNetGlassStyle, shape: GameNetGlassShape) -> some View {
        switch (style, shape) {
        case (.regular, .rect(let radius)):
            glassEffect(in: .rect(cornerRadius: radius))
        case (.tinted(let color, let opacity), .rect(let radius)):
            glassEffect(.regular.tint(color.opacity(opacity)), in: .rect(cornerRadius: radius))
        case (.regular, .capsule):
            glassEffect(in: .capsule)
        case (.tinted(let color, let opacity), .capsule):
            glassEffect(.regular.tint(color.opacity(opacity)), in: .capsule)
        case (.regular, .circle):
            glassEffect(in: .circle)
        case (.tinted(let color, let opacity), .circle):
            glassEffect(.regular.tint(color.opacity(opacity)), in: .circle)
        }
    }

    @ViewBuilder
    private func gameNetGlassFallback(style: GameNetGlassStyle, shape: GameNetGlassShape) -> some View {
        switch shape {
        case .rect(let radius):
            background {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay { tintOverlay(style: style, shape: .rect(cornerRadius: radius)) }
            }
        case .capsule:
            background {
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay { tintOverlay(style: style, shape: .capsule) }
            }
        case .circle:
            background {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay { tintOverlay(style: style, shape: .circle) }
            }
        }
    }

    @ViewBuilder
    private func tintOverlay(style: GameNetGlassStyle, shape: GameNetGlassShape) -> some View {
        if case .tinted(let color, let opacity) = style {
            switch shape {
            case .rect(let radius):
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(color.opacity(opacity))
            case .capsule:
                Capsule(style: .continuous)
                    .fill(color.opacity(opacity))
            case .circle:
                Circle()
                    .fill(color.opacity(opacity))
            }
        }
    }
}
