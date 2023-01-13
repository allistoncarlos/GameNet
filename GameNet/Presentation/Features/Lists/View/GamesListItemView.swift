//
//  GamesListItemView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 11/01/23.
//

import SwiftUI

// MARK: - GamesListItemView

struct GamesListItemView: View {
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: "https://images.nintendolife.com/da314926e706f/switch-tloz-totk-boxart-011.large.jpg")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: { ProgressView().progressViewStyle(.circular) }
            VStack {
                Text("The Legend of Zelda: Breath of the Wild")
                    .padding(4)
                    .background(.black)
                    .foregroundColor(.white)
                    .offset(x: -5, y: -5)
                    .font(.system(size: 10))
                Text("Nintendo Switch")
                Text("01/01/2019")
            }
        }
    }
}

// MARK: - GamesListItemView_Previews

struct GamesListItemView_Previews: PreviewProvider {
    static var previews: some View {
        GamesListItemView()
    }
}
