//
//  NowPlayingHighlightStyle.swift
//  GameNet
//
//  Variações de layout do destaque "Jogando agora" no Dashboard.
//

import Foundation

enum NowPlayingHighlightStyle: String, CaseIterable, Identifiable {
    case hero
    case banner
    case carousel

    // MARK: Internal

    static let storageKey = "dashboard.nowPlayingHighlightStyle"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .hero:
            return "Card"
        case .banner:
            return "Faixa"
        case .carousel:
            return "Carrossel"
        }
    }
}
