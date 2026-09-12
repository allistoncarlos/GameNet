//
//  InstagramStoryTemplate.swift
//  GameNet
//
//  Modelos visuais disponíveis para o story do Instagram.
//

import Foundation

enum InstagramStoryTemplate: String, CaseIterable, Identifiable {
    case poster
    case card
    case fullBleed

    // MARK: Internal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .poster: return "Pôster"
        case .card: return "Cartão"
        case .fullBleed: return "Capa cheia"
        }
    }

    var icon: String {
        switch self {
        case .poster: return "rectangle.portrait.on.rectangle.portrait"
        case .card: return "square.text.square"
        case .fullBleed: return "photo.fill"
        }
    }
}
