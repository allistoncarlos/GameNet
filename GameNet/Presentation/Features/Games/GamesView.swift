//
//  GamesView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import SwiftUI

// MARK: - GamesView

struct GamesView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                    .statusBarStyle(title: "Games", color: .main)

                Spacer()
            }
        }
    }
}

// MARK: - GamesView_Previews

struct GamesView_Previews: PreviewProvider {
    static var previews: some View {
        GamesView()
    }
}
