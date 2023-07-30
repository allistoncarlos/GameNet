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
    @StateObject var viewModel: EditListViewModel
    @State private var selectedUserGameId: String? = nil
    @Binding var navigationPath: NavigationPath

    var body: some View {
        Form {
            Section(header: Text("Título")) {
                TextField("Lista", text: $viewModel.list.name)
                    .autocapitalization(.none)
                    .onSubmit {
                        Task {
                            await viewModel.save()
                        }
                    }
            }

            if let listGame = viewModel.listGame {
                Section(header: Text("Jogos")) {
                    viewModel.showListGamesView(
                        navigationPath: $navigationPath,
                        listGame: listGame
                    )
                }
            } else if viewModel.list.name.isEmpty {
                EmptyView()
            } else {
                ProgressView()
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
        .scrollIndicators(.hidden)
        .onReceive(viewModel.$state) { state in
            if case .success = state {
                viewModel.goBackToLists(navigationPath: $navigationPath)
            }
        }
        .navigationView(title: viewModel.list.name.isEmpty ?
            "Nova Lista" : viewModel.list.name)
        .toolbar {
            Button(action: {}) {
                NavigationLink {
                    viewModel.showGameLookupView(
                        navigationPath: $navigationPath
                    )
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task {
            await viewModel.fetchGames()
        }
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
