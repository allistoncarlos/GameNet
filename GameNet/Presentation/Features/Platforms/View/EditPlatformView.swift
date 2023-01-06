//
//  EditPlatformView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 24/08/22.
//

import GameNet_Network
import SwiftUI

// MARK: - EditPlatformView

struct EditPlatformView: View {
    @ObservedObject var viewModel: EditPlatformViewModel
    @Binding var navigationPath: NavigationPath

    var body: some View {
        Form {
            TextField("Plataforma", text: $viewModel.platform.name)
                .autocapitalization(.none)
                .onSubmit {
                    Task {
                        await viewModel.save()
                    }
                }

            Section(
                footer:
                Button("Salvar") {
                    Task {
                        await viewModel.save()
                    }
                }
                .disabled(viewModel.platform.name.isEmpty || viewModel.state == .loading)
                .buttonStyle(MainButtonStyle())
            ) {
                EmptyView()
            }
        }
        .onReceive(viewModel.$state) { state in
            if case .success(_) = state {
                viewModel.goBackToPlatforms(navigationPath: $navigationPath)
            }
        }
        .navigationView(title: viewModel.platform.name.isEmpty ?
            "Nova Plataforma" : viewModel.platform.name)
    }
}

// MARK: - EditPlatformView_Previews

struct EditPlatformView_Previews: PreviewProvider {
    static var previews: some View {
        let _ = RepositoryContainer.platformRepository.register(factory: { MockPlatformRepository() })

        let platform = Platform(id: "1", name: "Nintendo Switch")

        ForEach(ColorScheme.allCases, id: \.self) {
            EditPlatformView(
                viewModel: EditPlatformViewModel(platform: platform),
                navigationPath: .constant(NavigationPath())
            ).preferredColorScheme($0)
        }
    }
}
