//
//  GameEditView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 21/03/23.
//

import SwiftUI

// MARK: - GameEditView

struct GameEditView: View {
    @ObservedObject var viewModel: GameEditViewModel
    @State var isLoading = true
    @Binding var navigationPath: NavigationPath

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

// MARK: - GameEditView_Previews

struct GameEditView_Previews: PreviewProvider {
    static var previews: some View {
        GameEditView(viewModel: GameEditViewModel(), navigationPath: .constant(NavigationPath()))
    }
}
