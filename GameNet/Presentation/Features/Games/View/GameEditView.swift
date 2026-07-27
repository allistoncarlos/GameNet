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
        Form {
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
                    .onChange(of: selectedImageItem) { _, newItem in
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
                    #endif
                }
            }

            Section("Dados do Jogo") {
                TextField("Nome", text: $viewModel.game.name)

                CurrencyTextField(title: "Preço (R$)", amountString: $viewModel.game.price)

                DatePicker(
                    "Data de Compra",
                    selection: $viewModel.game.boughtDate,
                    displayedComponents: .date
                )

                Toggle("Digital", isOn: $viewModel.game.digital)
                Toggle("Tenho", isOn: $viewModel.game.have)
                Toggle("Original", isOn: $viewModel.game.original)

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
        .disabled(isLoading)
        .navigationView(title: viewModel.isNewGame ? "Novo Jogo" : viewModel.game.name)
        .toolbar {
            Button("Salvar") {
                Task {
                    await viewModel.save()
                }
            }
        }
        .overlay(
            GameNetProgressHUD($isLoading, config: GameNetApp.hudConfig)
        )
        .onChange(of: viewModel.state) { _, state in
            isLoading = state == .loading
        }
        .task {
            await viewModel.fetchData()
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

#Preview("Dark Mode") {
    GameEditView(viewModel: GameEditViewModel(), navigationPath: .constant(NavigationPath())).preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    GameEditView(viewModel: GameEditViewModel(), navigationPath: .constant(NavigationPath())).preferredColorScheme(.light)
}

#if os(macOS)
import AppKit
#endif
