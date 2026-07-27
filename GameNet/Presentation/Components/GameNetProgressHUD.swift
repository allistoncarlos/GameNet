//
//  GameNetProgressHUD.swift
//  GameNet
//

import SwiftUI

struct GameNetHUDConfig {
    enum HUDType {
        case loading
        case success
    }

    var type: HUDType = .loading
    var title: String = "Carregando"
    var caption: String = ""
    var shouldAutoHide: Bool = false
    var allowsTapToHide: Bool = false
    var autoHideInterval: TimeInterval = 3.0

    static let loading = GameNetHUDConfig(
        title: "Carregando",
        caption: "Aguarde enquanto os dados\nsão retornados do servidor"
    )
}

struct GameNetProgressHUD: View {
    @Binding var isPresented: Bool
    let config: GameNetHUDConfig

    init(_ isPresented: Binding<Bool>, config: GameNetHUDConfig) {
        _isPresented = isPresented
        self.config = config
    }

    var body: some View {
        #if os(iOS)
        TTProgressHUDBridge(isPresented: $isPresented, config: config)
        #else
        macHUD
        #endif
    }

    @ViewBuilder
    private var macHUD: some View {
        if isPresented {
            ZStack {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    if config.type == .success {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.green)
                    } else {
                        ProgressView()
                            .controlSize(.large)
                    }

                    Text(config.title)
                        .font(.headline)

                    if !config.caption.isEmpty {
                        Text(config.caption)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(24)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 12)
            }
            .transition(.opacity)
            .onTapGesture {
                if config.allowsTapToHide {
                    isPresented = false
                }
            }
            .onAppear {
                guard config.shouldAutoHide else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + config.autoHideInterval) {
                    isPresented = false
                }
            }
        }
    }
}

#if os(iOS)
import TTProgressHUD

private struct TTProgressHUDBridge: View {
    @Binding var isPresented: Bool
    let config: GameNetHUDConfig

    var body: some View {
        TTProgressHUD($isPresented, config: TTProgressHUDConfig(
            type: config.type == .success ? .success : .loading,
            title: config.title,
            caption: config.caption,
            shouldAutoHide: config.shouldAutoHide,
            allowsTapToHide: config.allowsTapToHide,
            autoHideInterval: config.autoHideInterval
        ))
    }
}
#endif

extension View {
    func gameNetProgressHUD(_ isPresented: Binding<Bool>, config: GameNetHUDConfig = .loading) -> some View {
        overlay {
            GameNetProgressHUD(isPresented, config: config)
        }
    }
}
