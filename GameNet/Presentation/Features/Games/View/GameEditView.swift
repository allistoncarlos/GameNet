//
//  GameEditView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 21/03/23.
//

import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct GameEditView: View {

    @StateObject var viewModel: GameEditViewModel
    @Binding var navigationPath: NavigationPath
    @State var isLoading = true
    @State var isEmptyImage = true

    var body: some View {
        formContent
            .disabled(isLoading)
            .navigationView(title: viewModel.isNewGame ? "Novo Jogo" : viewModel.game.name)
            .toolbar {
                if viewModel.isNewGame {
                    importToolbarButton
                }
                saveToolbarButton
            }
            .overlay(
                GameNetProgressHUD($isLoading, config: GameNetApp.hudConfig)
            )
            .onChangeCompat(of: viewModel.state) { state in
                isLoading = state == .loading
            }
            .onChangeCompat(of: viewModel.selectedImageData) { data in
                isEmptyImage = data == nil
            }
            .sheet(isPresented: $viewModel.isImportPresented) {
                GameImportSheet(viewModel: viewModel)
            }
            .task {
                await viewModel.fetchData()
            }
    }

    private var formContent: some View {
        Form {
            coverImageSection
            gameDataSection
            userDataSection
        }
    }

    private var coverImageSection: some View {
        Section("Escolha a imagem de capa") {
            VStack {
                if let selectedImageData = viewModel.selectedImageData,
                   let image = PlatformImage.swiftUIImage(from: selectedImageData) {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, idealHeight: 240)
                        .padding(20)
                }

                #if os(iOS)
                PhotosPicker(
                    selection: $selectedImageItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    imagePickerLabel
                }
                .onChangeCompat(of: selectedImageItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            viewModel.selectedImageData = data
                            isEmptyImage = viewModel.selectedImageData == nil
                        }
                    }
                }
                #elseif os(macOS)
                Button("Escolher imagem") {
                    pickImageOnMac()
                }
                #else
                Text("Selecione a capa no iPhone ou Mac.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                #endif
            }
        }
    }

    private var gameDataSection: some View {
        Section("Dados do Jogo") {
            TextField("Nome", text: $viewModel.game.name)

            Picker(
                "Plataforma",
                selection: Binding($viewModel.game.platform, deselectTo: nil)
            ) {
                if let selectedPlatform = viewModel.game.platform {
                    if !viewModel.platforms.contains(selectedPlatform) {
                        Text(String()).tag(nil as Platform?)
                    }
                } else {
                    Text(String()).tag(nil as Platform?)
                }

                ForEach(viewModel.platforms, id: \.id) { platform in
                    Text(platform.name)
                        .tag(platform as Platform?)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var userDataSection: some View {
        Section("Dados do Usuário") {
            CurrencyTextField(title: "Preço (R$)", amountString: $viewModel.game.price)

            #if os(tvOS)
            LabeledContent("Data de Compra") {
                Text(
                    viewModel.game.boughtDate,
                    format: .dateTime.day().month().year()
                )
            }
            #else
            DatePicker(
                "Data de Compra",
                selection: $viewModel.game.boughtDate,
                displayedComponents: .date
            )
            #endif

            Toggle("Digital", isOn: $viewModel.game.digital)
            Toggle("Tenho", isOn: $viewModel.game.have)
            Toggle("Original", isOn: $viewModel.game.original)
        }
    }

    private var saveToolbarButton: some View {
        Button("Salvar") {
            Task {
                await viewModel.save()
            }
        }
    }

    private var importToolbarButton: some View {
        Button("Importar") {
            viewModel.openImport()
        }
    }

    #if os(iOS)
    @State private var selectedImageItem: PhotosPickerItem? = nil
    #endif

    private var imagePickerLabel: some View {
        Group {
            if isEmptyImage {
                Image(systemName: "arrow.up.bin")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, idealHeight: 240)
                    .foregroundColor(Color.main)
                    .padding(20)
            }
        }
    }

    #if os(macOS)
    private func pickImageOnMac() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK, let url = panel.url,
           let data = try? Data(contentsOf: url) {
            viewModel.selectedImageData = data
            isEmptyImage = false
        }
    }
    #endif
}

#if os(macOS)
import AppKit
#endif
