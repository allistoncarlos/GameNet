//
//  NowPlayingSessionTimer.swift
//  GameNet
//
//  Cronômetro da sessão de gameplay em andamento.
//

import SwiftUI

struct NowPlayingSessionTimer: View {
    let start: Date
    var font: Font = .dashboardGameTitle

    var body: some View {
        TimelineView(.periodic(from: Date(), by: 1)) { context in
            Text(Self.elapsedText(from: start, to: context.date))
                .font(font)
                .monospacedDigit()
        }
        .accessibilityLabel("Tempo de sessão")
    }

    static func elapsedText(from start: Date, to now: Date) -> String {
        let totalSeconds = max(0, Int(now.timeIntervalSince(start)))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// MARK: - NowPlayingPulseDot

struct NowPlayingPulseDot: View {
    var size: CGFloat = 8
    var color: Color = .main

    @State private var isPulsing = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .opacity(isPulsing ? 0.35 : 1)
            .animation(
                .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
            .accessibilityHidden(true)
    }
}
