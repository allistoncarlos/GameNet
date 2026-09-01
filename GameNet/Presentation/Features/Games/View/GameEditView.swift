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
    #if os(macOS)
    @State private var isCoverDropTargeted = false
    #endif

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
                    #if os(macOS)
                    .frame(minWidth: 520, minHeight: 480)
                    #endif
            }
            .task {
                await viewModel.fetchData()
            }
    }

    @ViewBuilder
    private var formContent: some View {
        #if os(macOS)
        macEditor
        #else
        Form {
            coverImageSection
            gameDataSection
            userDataSection
        }
        #endif
    }

    #if !os(macOS)
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

            platformPicker
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
    #endif

    private var platformPicker: some View {
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

    #if !os(macOS)
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
    #endif
}

#if os(macOS)
import AppKit

private extension GameEditView {
    var macEditor: some View {
        GeometryReader { proxy in
            let maxWidth = min(920, max(proxy.size.width - 48, 0))
            let usesSideBySide = proxy.size.width >= 760

            ScrollView {
                Group {
                    if usesSideBySide {
                        HStack(alignment: .top, spacing: 24) {
                            macCoverColumn
                            macFields
                        }
                    } else {
                        VStack(alignment: .center, spacing: 24) {
                            macCoverColumn
                            macFields
                        }
                    }
                }
                .frame(maxWidth: maxWidth, alignment: .leading)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, PlatformMetrics.horizontalPadding(for: proxy.size.width))
                .padding(.vertical, 24)
            }
        }
    }

    var macCoverColumn: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Capa")
                .font(.headline)
                .padding(.leading, 4)

            macCoverPicker
        }
    }

    var macCoverPicker: some View {
        Button(action: pickImageOnMac) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.primaryCardBackground)

                if let selectedImageData = viewModel.selectedImageData,
                   let image = PlatformImage.swiftUIImage(from: selectedImageData) {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "arrow.up.bin")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundStyle(Color.main)

                        Text("Escolher imagem")
                            .font(.headline)

                        Text("ou arraste um arquivo")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                }
            }
            .frame(width: 220, height: 330)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        isCoverDropTargeted ? Color.main : Color.main.opacity(0.16),
                        style: StrokeStyle(
                            lineWidth: isCoverDropTargeted ? 2.5 : 1,
                            dash: isEmptyImage ? [7] : []
                        )
                    )
            }
            .overlay(alignment: .bottom) {
                if !isEmptyImage {
                    Text("Alterar capa")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.bottom, 12)
                }
            }
        }
        .buttonStyle(.plain)
        .onDrop(of: [.image, .fileURL], isTargeted: $isCoverDropTargeted) { providers in
            loadDroppedImage(from: providers)
        }
        .help("Clique para escolher a capa ou arraste uma imagem")
    }

    var macFields: some View {
        VStack(alignment: .leading, spacing: 16) {
            macSectionCard(title: "Dados do Jogo") {
                macLabeledField("Nome") {
                    TextField("Nome do jogo", text: $viewModel.game.name)
                        .textFieldStyle(.plain)
                }

                macLabeledControl("Plataforma") {
                    platformPicker
                        .labelsHidden()
                        .frame(minWidth: 180, maxWidth: .infinity, alignment: .leading)
                }
            }

            macSectionCard(title: "Dados do Usuário") {
                HStack(alignment: .top, spacing: 16) {
                    macLabeledField("Preço (R$)") {
                        CurrencyTextField(title: "0,00", amountString: $viewModel.game.price)
                            .textFieldStyle(.plain)
                    }

                    macLabeledControl("Data de Compra") {
                        DatePicker(
                            "Data de Compra",
                            selection: $viewModel.game.boughtDate,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        .datePickerStyle(.field)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                HStack(spacing: 20) {
                    Toggle("Digital", isOn: $viewModel.game.digital)
                    Toggle("Tenho", isOn: $viewModel.game.have)
                    Toggle("Original", isOn: $viewModel.game.original)
                }
                .toggleStyle(.switch)
                .controlSize(.small)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func macSectionCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)

            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.primaryCardBackground)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.main.opacity(0.10), lineWidth: 1)
        }
    }

    func macLabeledField<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            content()
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.secondaryCardBackground.opacity(0.65))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.main.opacity(0.08), lineWidth: 1)
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func macLabeledControl<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            content()
                .frame(minHeight: 32, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func pickImageOnMac() {
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

    func loadDroppedImage(from providers: [NSItemProvider]) -> Bool {
        if let imageProvider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.image.identifier) }) {
            imageProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
                applyDroppedImageData(data)
            }
            return true
        }

        guard let urlProvider = providers.first(where: {
            $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier)
        }) else {
            return false
        }

        urlProvider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
            let url: URL?
            if let data = item as? Data {
                url = URL(dataRepresentation: data, relativeTo: nil)
            } else {
                url = item as? URL
            }

            guard let url else { return }
            let accessed = url.startAccessingSecurityScopedResource()
            defer {
                if accessed {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            guard let data = try? Data(contentsOf: url) else { return }
            applyDroppedImageData(data)
        }

        return true
    }

    func applyDroppedImageData(_ data: Data?) {
        guard let data else { return }

        Task { @MainActor in
            viewModel.selectedImageData = data
            isEmptyImage = false
        }
    }
}
#endif
