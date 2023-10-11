//
//  EditListView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 11/01/23.
//

import GameNet_Network
import SwiftUI
import TTProgressHUD

// MARK: - EditListView

struct EditListView: View {

    // MARK: Internal

    @StateObject var viewModel: EditListViewModel
    @Binding var navigationPath: NavigationPath
    @State var isLoading = true

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
                .disabled(isLoading || viewModel.list.name.isEmpty)
                .buttonStyle(MainButtonStyle())
            ) {
                EmptyView()
            }
        }
        .disabled(isLoading)
        .scrollIndicators(.hidden)
        .onReceive(viewModel.$state) { state in
            if case .success = state {
                viewModel.goBackToLists(navigationPath: $navigationPath)
            } else if case .idle = state {
                isLoading = false
            }
        }
        .navigationView(title: viewModel.list.name.isEmpty ?
            "Nova Lista" : viewModel.list.name)
        .toolbar {
            Button(action: {
                self.isGameSelectionSheetPresented = true
            }) {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $isGameSelectionSheetPresented) {
            viewModel.showGameLookupView(
                selectedUserGameId: $selectedUserGameId,
                isPresented: $isGameSelectionSheetPresented
            )
        }
        .overlay(
            TTProgressHUD($isLoading, config: GameNetApp.hudConfig)
        )
        .onChange(of: viewModel.state) { state in
            isLoading = state == .loading
        }
        .onChange(of: selectedUserGameId, perform: { newValue in
            Task {
                await viewModel.addUserGame(selectedUserGameId: $selectedUserGameId)
                self.selectedUserGameId = nil
            }
        })
        .task {
            await viewModel.fetchGames()
        }
    }

    // MARK: Private

    @State private var isGameSelectionSheetPresented = false
    @State private var selectedUserGameId: String? = nil

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
