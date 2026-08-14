//
//  GameImportSheet.swift
//  GameNet
//

import SwiftUI

struct GameImportSheet: View {
    @ObservedObject var viewModel: GameEditViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            SwiftUI.List {
                if let platform = viewModel.game.platform {
                    Section {
                        Text("Capa: \(PlatformCoverResolver.parse(platform.name).coverSearchName)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Busca") {
                    TextField("Nome do jogo", text: $viewModel.importQuery)
                        .onSubmit {
                            Task { await viewModel.searchImport() }
                        }

                    Button("Buscar na TheGamesDB") {
                        Task { await viewModel.searchImport() }
                    }
                    .disabled(viewModel.importQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                if viewModel.isImporting {
                    Section {
                        ProgressView()
                    }
                }

                if let importMessage = viewModel.importMessage {
                    Section {
                        Text(importMessage)
                            .foregroundStyle(.red)
                    }
                }

                if !viewModel.importResults.isEmpty {
                    Section("Resultados") {
                        ForEach(viewModel.importResults) { game in
                            Button {
                                Task { await viewModel.applyImport(game) }
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(game.name)
                                    if let platformName = game.platformName, !platformName.isEmpty {
                                        Text(platformName)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    if let released = game.released, !released.isEmpty {
                                        Text(released)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Importar")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
            .task {
                if !viewModel.importQuery.isEmpty {
                    await viewModel.searchImport()
                }
            }
        }
    }
}
