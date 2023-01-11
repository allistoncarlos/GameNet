//
//  EditListView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 11/01/23.
//

import GameNet_Network
import SwiftUI

// MARK: - EditListView

struct EditListView: View {
    @ObservedObject var viewModel: EditListViewModel
    @Binding var navigationPath: NavigationPath

    var body: some View {
        Form {
            TextField("Lista", text: $viewModel.list.name)
                .autocapitalization(.none)
                .onSubmit {
                    Task {
                        await viewModel.save()
                    }
                }

            Section(
                footer:
                Button("Salvar") {
                    Task {
                        await viewModel.save()
                    }
                }
                .disabled(viewModel.list.name.isEmpty || viewModel.state == .loading)
                .buttonStyle(MainButtonStyle())
            ) {
                EmptyView()
            }
        }
        .onReceive(viewModel.$state) { state in
            if case .success(_) = state {
                viewModel.goBackToLists(navigationPath: $navigationPath)
            }
        }
        .navigationView(title: viewModel.list.name.isEmpty ?
            "Nova Lista" : viewModel.list.name)
    }
}

// MARK: - EditListView_Previews

struct EditListView_Previews: PreviewProvider {
    static var previews: some View {
        let _ = RepositoryContainer.listRepository.register(factory: { MockListRepository() })

        let list = GameNet_Network.List(id: "1", name: "Próximos Jogos")
        
        ForEach(ColorScheme.allCases, id: \.self) {
            EditListView(
                viewModel: EditListViewModel(list: list),
                navigationPath: .constant(NavigationPath())
            ).preferredColorScheme($0)
        }
    }
}
