//
//  GameItemView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 25/07/23.
//

import CachedAsyncImage
import SwiftUI

// MARK: - GameItemView

struct GameItemView: View {
    var name: String
    var coverURL: String

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            CachedAsyncImage(url: URL(string: coverURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: { ProgressView().progressViewStyle(.circular) }
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
    let _ = RepositoryContainer.gameRepository.register(factory: { MockGameRepository() })
    
    if let game = MockGameRepository().fetchData(id: "1") {
        GameItemView(name: game.name, coverURL: game.cover).preferredColorScheme(.dark)
    }
}

#Preview("Light Mode") {
    let _ = RepositoryContainer.gameRepository.register(factory: { MockGameRepository() })
    
    if let game = MockGameRepository().fetchData(id: "1") {
        GameItemView(name: game.name, coverURL: game.cover).preferredColorScheme(.light)
    }
}
