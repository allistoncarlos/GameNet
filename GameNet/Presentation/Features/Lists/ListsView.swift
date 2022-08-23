//
//  ListsView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import SwiftUI

// MARK: - ListsView

struct ListsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                    .statusBarStyle(title: "Lists", color: .main)

                Spacer()
            }
        }
    }
}

// MARK: - ListsView_Previews

struct ListsView_Previews: PreviewProvider {
    static var previews: some View {
        ListsView()
    }
}
