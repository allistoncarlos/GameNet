//
//  GamesListItemView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 11/01/23.
//

import GameNet_Network
import SwiftUI

// MARK: - GamesListItemView

struct GamesListItemView: View {
    var game: ListItem? = nil
    var itemDetail: String? = nil

    // MARK: - Constants

    let fixedHeight: CGFloat = 100
    let fixedWidth: CGFloat = 60

    var body: some View {
        NavigationLink(value: game) {
            HStack(spacing: 20) {
                AsyncImage(url: URL(string: game?.cover ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: fixedWidth, height: fixedHeight, alignment: .trailing)
                        .listRowInsets(EdgeInsets())
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(width: fixedWidth, height: fixedHeight, alignment: .trailing)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(game?.name ?? "")
                        .font(.system(size: 20).bold())
                    Text(game?.platform ?? "")
                        .font(.system(size: 16).bold())

                    if let itemDetail {
                        Text(itemDetail)
                    }
                }
                Spacer()
            }
        }
        .frame(height: fixedHeight)
    }
}

// MARK: - GamesListItemView_Previews

struct GamesListItemView_Previews: PreviewProvider {
    static var previews: some View {
        let listGame = MockListRepository().fetchData(id: "1")

        GamesListItemView(
            game: listGame?.games?[0]
        )
    }
}
