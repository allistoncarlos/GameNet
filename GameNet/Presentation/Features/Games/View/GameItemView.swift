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
                .background(.black)
                .foregroundColor(.white)
                .offset(x: -5, y: -5)
                .font(.system(size: 10))
        }
    }
}

// MARK: - GameItemView_Previews

struct GameItemView_Previews: PreviewProvider {
    static var previews: some View {
        let _ = RepositoryContainer.gameRepository.register(factory: { MockGameRepository() })

        if let game = MockGameRepository().fetchData(id: "1") {
            GameItemView(name: game.name, coverURL: game.cover)
        } else {
            EmptyView()
        }
    }
}
