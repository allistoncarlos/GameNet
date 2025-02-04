//
//  GameEditView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 21/03/23.
//

import GameNet_Network
import PhotosUI
import SwiftUI
import TTProgressHUD

// MARK: - GameEditView

struct GameEditView: View {

    // MARK: Internal

    @StateObject var viewModel: GameEditViewModel
    @Binding var navigationPath: NavigationPath
    @State var isLoading = true
    @State var isEmptyImage = true

    var body: some View {
        Form {
            Section("Escolha a imagem de capa") {
                VStack {
                    if let selectedImageData = viewModel.selectedImageData,
                       let uiImage = UIImage(data: selectedImageData) {
                        Image(uiImage: uiImage)
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
                        if isEmptyImage {
                            Image(systemName: "arrow.up.bin")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, idealHeight: 240)
                                .foregroundColor(Color.main)
                                .padding(20)
                        }
                    }
                    .onChange(of: selectedImageItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                viewModel.selectedImageData = data
                                
                                isEmptyImage = viewModel.selectedImageData == nil
                            }
                        }
                    }
#endif
                }
            }

            Section("Dados do Jogo") {
                TextField("Nome", text: $viewModel.game.name)

                CurrencyTextField(title: "Preço (R$)", amountString: $viewModel.game.price)

#if os(iOS)
                DatePicker(
                    "Data de Compra",
                    selection: $viewModel.game.boughtDate,
                    displayedComponents: .date
                )
#endif

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
            TTProgressHUD($isLoading, config: GameNetApp.hudConfig)
        )
        .onChange(of: viewModel.state) { _, state in
            isLoading = state == .loading
        }
        .task {
            await viewModel.fetchData()
        }
    }

    // MARK: Private

#if os(iOS)
    @State private var selectedImageItem: PhotosPickerItem? = nil
#endif

    var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter
    }()

}

// MARK: - Previews

#Preview("Dark Mode") {
    GameEditView(viewModel: GameEditViewModel(), navigationPath: .constant(NavigationPath())).preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    GameEditView(viewModel: GameEditViewModel(), navigationPath: .constant(NavigationPath())).preferredColorScheme(.light)
}
