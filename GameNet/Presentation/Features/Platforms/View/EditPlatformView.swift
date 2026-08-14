//
//  EditPlatformView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 24/08/22.
//

import Factory
import SwiftUI

struct EditPlatformView: View {
    @ObservedObject var viewModel: EditPlatformViewModel
    @Binding var navigationPath: NavigationPath

    var body: some View {
        Form {
            TextField("Plataforma", text: $viewModel.platform.name)
                #if os(iOS)
                .autocapitalization(.none)
                #endif
                .disabled(viewModel.platform.id != nil)
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
                .disabled(
                    viewModel.platform.name.isEmpty
                        || viewModel.platform.id != nil
                        || viewModel.state == .loading
                )
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
        .navigationView(title: "Nova Plataforma")
    }
}
