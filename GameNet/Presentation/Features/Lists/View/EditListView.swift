//
//  EditListView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 11/01/23.
//

import Factory
import SwiftUI

// MARK: - EditListView

struct EditListView: View {

    // MARK: Internal

    @StateObject var viewModel: EditListViewModel
    @Binding var navigationPath: NavigationPath
    @State var isLoading = true

    var body: some View {
        Form {
            Section(header: Text("Título")) {
                TextField("Lista", text: $viewModel.listGame.name)
                    #if os(iOS)
                    .autocapitalization(.none)
                    #endif
                    .onSubmit {
                        Task {
                            await viewModel.save()
                        }
                    }
            }

            if viewModel.listGame.games != nil {
                Section(header: Text("Jogos")) {
                    viewModel.showListGamesView(
                        navigationPath: $navigationPath,
                        listGame: viewModel.listGame,
                        deleteAction: delete(at:),
                        moveAction: move(from:to:)
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
                .disabled(isLoading || viewModel.listGame.name.isEmpty)
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
            GameNetProgressHUD($isLoading, config: GameNetApp.hudConfig)
        )
        .onChangeCompat(of: viewModel.state) { state in
            isLoading = state == .loading
        }
        .onChangeCompat(of: selectedUserGameId) { _ in
            Task {
                await viewModel.addUserGame(selectedUserGameId: $selectedUserGameId)
                self.selectedUserGameId = nil
            }
        }
        .task {
            await viewModel.fetchGames()
        }
    }
    
    func delete(at offsets: IndexSet) {
        viewModel.delete(at: offsets)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        viewModel.move(from: source, to: destination)
    }

    // MARK: Private

    @State private var isGameSelectionSheetPresented = false
    @State private var selectedUserGameId: String? = nil

}
