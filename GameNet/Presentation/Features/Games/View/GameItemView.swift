//
//  GameItemView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 25/07/23.
//

import Factory
import SwiftUI

// MARK: - GameItemView

struct GameItemView: View {
    var name: String
    var coverURL: String
    var gameId: String? = nil

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            GameCover3DView(
                coverURL: coverURL,
                cornerRadius: 8,
                enablesMotion: false,
                autoRotate: true
            )
            .aspectRatio(2 / 3, contentMode: .fit)
            .gameCoverTransitionSource(id: gameId)

            Text(name)
                .padding(4)
                .foregroundColor(.white)
                .font(.system(size: 10))
                .glassEffect()
        }
    }
}

// MARK: - Previews

#Preview("Dark Mode") {
    let _ = Container.shared.gameRepository.register(factory: { MockGameRepository() })
    
    if let game = MockGameRepository().fetchData(id: "1") {
        GameItemView(name: game.name, coverURL: game.cover).preferredColorScheme(.dark)
    }
}

#Preview("Light Mode") {
    let _ = Container.shared.gameRepository.register(factory: { MockGameRepository() })
    
    if let game = MockGameRepository().fetchData(id: "1") {
        GameItemView(name: game.name, coverURL: game.cover).preferredColorScheme(.light)
    }
}
