//
//  NowPlayingStylePicker.swift
//  GameNet
//
//  Seletor (somente DEBUG) das variações do destaque "Jogando agora".
//

#if DEBUG && (os(iOS) || os(macOS))
import SwiftUI

struct NowPlayingStylePicker: View {
    @Binding var rawValue: String

    var body: some View {
        Picker("Destaque", selection: selection) {
            ForEach(NowPlayingHighlightStyle.allCases) { style in
                Text(style.title).tag(style)
            }
        }
        .pickerStyle(.segmented)
        .dashboardOuterPadding()
        .accessibilityIdentifier("now-playing-style-picker")
    }

    // MARK: Private

    private var selection: Binding<NowPlayingHighlightStyle> {
        Binding(
            get: { NowPlayingHighlightStyle(rawValue: rawValue) ?? .hero },
            set: { rawValue = $0.rawValue }
        )
    }
}
#endif
