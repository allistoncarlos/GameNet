//
//  iOS16Compatibility.swift
//  GameNet
//
//  Fallbacks para APIs de iOS 17+ quando o deployment é iOS 16.5.
//  Em iOS 17/26 o comportamento nativo é preservado.
//

import SwiftUI

extension View {
    /// `onChange` de dois parâmetros (iOS 17+) com fallback para iOS 16.
    @ViewBuilder
    func onChangeCompat<V: Equatable>(of value: V, perform action: @escaping (_ newValue: V) -> Void) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            onChange(of: value) { _, newValue in
                action(newValue)
            }
        } else {
            onChange(of: value, perform: action)
        }
    }

    /// Item de carrossel com `containerRelativeFrame` + `scrollTransition` no iOS 17+.
    @ViewBuilder
    func pagingCarouselItem(scaleWhenIdle: CGFloat = 0.8) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, *) {
            containerRelativeFrame(.horizontal)
                .scrollTransition(axis: .horizontal) { content, phase in
                    content.scaleEffect(
                        x: phase.isIdentity ? 1 : scaleWhenIdle,
                        y: phase.isIdentity ? 1 : scaleWhenIdle
                    )
                }
        } else {
            self
        }
    }

    @ViewBuilder
    func gameNetCircleButtonBorder() -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, *) {
            buttonBorderShape(.circle)
        } else {
            clipShape(Circle())
        }
    }

    @ViewBuilder
    func gameNetInlineToolbarTitle() -> some View {
        #if os(iOS)
        if #available(iOS 17.0, *) {
            toolbarTitleDisplayMode(.inline)
        } else {
            self
        }
        #else
        self
        #endif
    }

    /// `onGeometryChange` (iOS 18+) com fallback via GeometryReader no iOS 16/17.
    @ViewBuilder
    func onWidthChange(_ action: @escaping (CGFloat) -> Void) -> some View {
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, *) {
            onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.width
            } action: { newWidth in
                action(newWidth)
            }
        } else {
            background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { action(proxy.size.width) }
                        .onChangeCompat(of: proxy.size.width, perform: action)
                }
            }
        }
    }
}

extension Animation {
    static var gameNetSmooth: Animation {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            return .smooth
        } else {
            return .easeInOut
        }
    }

    static var gameNetSnappy: Animation {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            return .snappy
        } else {
            return .spring()
        }
    }
}
