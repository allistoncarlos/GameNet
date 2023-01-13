//
//  ListsView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import SwiftUI

// MARK: - ListsView

struct ListsView: View {

    // MARK: Internal

    @ObservedObject var viewModel: ListsViewModel

    var body: some View {
        NavigationStack(path: $presentedLists) {
            VStack {
                if viewModel.state == .loading {
                    ProgressView()
                } else {
                    if let lists = viewModel.lists {
                        List(lists, id: \.id) { list in
                            NavigationLink(list.name, value: list.id)
                        }
                    }
                }
            }
            .navigationDestination(for: String.self) { listId in
                viewModel.editListView(navigationPath: $presentedLists, listId: listId)
            }
            .navigationView(title: "Listas")
            .toolbar {
                Button(action: {}) {
                    NavigationLink(value: String()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .onChange(of: presentedLists) { newValue in
            if newValue.isEmpty {
                Task {
                    await viewModel.fetchData()
                }
            }
        }
        .task {
            await viewModel.fetchData()
        }
    }

    // MARK: Private

    @State private var presentedLists = NavigationPath()
}

// MARK: - ListsView_Previews

struct ListsView_Previews: PreviewProvider {
    // TODO: CRIAR TELA DE DETALHE DE LISTA, E COLOCAR NO DASHBOARD
    static var previews: some View {
        let _ = RepositoryContainer.listRepository.register(factory: { MockListRepository() })

        ForEach(ColorScheme.allCases, id: \.self) {
            ListsView(viewModel: ListsViewModel()).preferredColorScheme($0)
        }
    }
}
