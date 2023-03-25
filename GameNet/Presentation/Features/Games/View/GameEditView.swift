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

    @ObservedObject var viewModel: GameEditViewModel
    @Binding var navigationPath: NavigationPath
    @State var isLoading = true

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Form {
                Section("Escolha a imagem de capa") {
                    VStack {
                        if let selectedImageData,
                           let uiImage = UIImage(data: selectedImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, idealHeight: 240)
                                .padding(20)
                        }

                        PhotosPicker(
                            selection: $selectedImageItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            if selectedImageData == nil {
                                Image(systemName: "arrow.up.bin")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, idealHeight: 240)
                                    .foregroundColor(Color.main)
                                    .padding(20)
                            }
                        }
                        .onChange(of: selectedImageItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                }
                            }
                        }
                    }
                }

                Section("Dados do Jogo") {
                    TextField("Nome", text: $viewModel.game.name)

                    CurrencyTextField(
                        "Preço (R$)",
                        value: $viewModel.game.price,
                        currencySymbol: "R$"
                    )

                    DatePicker(
                        "Data de Compra",
                        selection: $viewModel.game.boughtDate,
                        displayedComponents: .date
                    )

                    Toggle("Digital", isOn: $viewModel.game.digital)
                    Toggle("Tenho", isOn: $viewModel.game.have)
                    Toggle("Original", isOn: $viewModel.game.original)
                }
            }
            .disabled(isLoading)
            .navigationView(title: viewModel.isNewGame ? "Novo Jogo" : "MUDAR")
        }
        .overlay(
            TTProgressHUD($isLoading, config: GameNetApp.hudConfig)
        )
        .onChange(of: viewModel.state) { state in
            isLoading = state == .loading
        }
        .task {
            await viewModel.fetchData()
        }
    }

    // MARK: Private

    @State private var selectedImageItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil

    var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter
    }()

}

// MARK: - GameEditView_Previews

struct GameEditView_Previews: PreviewProvider {
    static var previews: some View {
        GameEditView(viewModel: GameEditViewModel(), navigationPath: .constant(NavigationPath()))
    }
}
