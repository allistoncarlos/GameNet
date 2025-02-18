//
//  EditPlatformView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 24/08/22.
//

#if os(iOS)
import GameNet_Network
import SwiftUI
import SwiftData

// MARK: - EditPlatformView

struct EditPlatformView: View {
    @ObservedObject var viewModel: EditPlatformViewModel
    @Binding var navigationPath: NavigationPath
    @StateObject var networkConnectivity = NetworkConnectivity()

    var body: some View {
        Form {
            TextField("Plataforma", text: $viewModel.platform.name)
                .autocapitalization(.none)
                .onSubmit {
                    Task {
                        await viewModel.save(isConnected: networkConnectivity.status == .connected)
                    }
                }

            Section(
                footer:
                Button("Salvar") {
                    Task {
                        await viewModel.save(isConnected: networkConnectivity.status == .connected)
                    }
                }
                .disabled(viewModel.platform.name.isEmpty || viewModel.state == .loading)
                .buttonStyle(MainButtonStyle())
            ) {
                EmptyView()
            }
        }
        .onReceive(viewModel.$state) { state in
            if case .success = state {
                viewModel.goBackToPlatforms(navigationPath: $navigationPath)
            }
        }
        .navigationView(title: viewModel.platform.name.isEmpty ?
            "Nova Plataforma" : viewModel.platform.name)
    }
}

// MARK: - Previews

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let _ = RepositoryContainer.platformRepository.register(factory: { MockPlatformRepository() })
    let platform = Platform(id: "1", name: "Nintendo Switch")

    EditPlatformView(
        viewModel: EditPlatformViewModel(
            platform: platform,
            modelContext: ModelContext(
                try! ModelContainer(for: Platform.self, configurations: config)
            )
        ),
        navigationPath: .constant(NavigationPath())
    )
    .modelContainer(for: Platform.self, inMemory: true)
    .preferredColorScheme(.dark)
}
#endif
