//
//  GameListFilter.swift
//  GameNet
//

import Foundation

enum GameListFilter: String, CaseIterable, Identifiable {
    case all
    case digital
    case physical
    case finished
    case playing
    case original

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "Todos"
        case .digital: return "Digitais"
        case .physical: return "Físicos"
        case .finished: return "Finalizados"
        case .playing: return "Jogando"
        case .original: return "Originais"
        }
    }

    var queryValue: String? {
        self == .all ? nil : rawValue
    }
}
