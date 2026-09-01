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
            importContent
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
        #if os(macOS)
        .frame(minWidth: 520, idealWidth: 560, minHeight: 480, idealHeight: 560)
        #endif
    }

    @ViewBuilder
    private var importContent: some View {
        #if os(macOS)
        macImportContent
        #else
        iosImportContent
        #endif
    }

    #if !os(macOS)
    private var iosImportContent: some View {
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
                .disabled(isSearchDisabled)
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
                        resultButton(for: game)
                    }
                }
            }
        }
    }
    #endif

    #if os(macOS)
    private var macImportContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let platform = viewModel.game.platform {
                Text("Capa: \(PlatformCoverResolver.parse(platform.name).coverSearchName)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                TextField("Nome do jogo", text: $viewModel.importQuery)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        Task { await viewModel.searchImport() }
                    }

                Button("Buscar") {
                    Task { await viewModel.searchImport() }
                }
                .disabled(isSearchDisabled)
                .keyboardShortcut(.defaultAction)
            }

            if viewModel.isImporting {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }

            if let importMessage = viewModel.importMessage {
                Text(importMessage)
                    .foregroundStyle(.red)
            }

            if viewModel.importResults.isEmpty, !viewModel.isImporting, viewModel.importMessage == nil {
                Text("Busque um jogo na TheGamesDB para preencher nome e capa.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.importResults) { game in
                            resultButton(for: game)
                                .buttonStyle(.plain)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .background {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Color.secondaryCardBackground.opacity(0.35))
                                }
                                .padding(.bottom, 6)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    #endif

    private var isSearchDisabled: Bool {
        viewModel.importQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || viewModel.isImporting
    }

    private func resultButton(for game: TheGamesDBGame) -> some View {
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
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
