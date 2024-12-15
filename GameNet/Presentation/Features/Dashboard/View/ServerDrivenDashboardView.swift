//
//  ServerDrivenDashboardView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 23/11/24.
//

import SwiftUI
import TTProgressHUD
import CachedAsyncImage

struct ServerDrivenDashboardView: View {
    @ObservedObject var viewModel: ServerDrivenDashboardViewModel
    @State var isLoading = true
    
    var body: some View {
        VStack(spacing: -20) {
            if let dynamicContainer = viewModel.dynamicContainer {
                renderChildren(components: [dynamicContainer])
            }
        }
        .disabled(isLoading)
        // TODO: Essa parte aqui tenho que ver em relação ao loading da página raíz
//        .overlay(
//            TTProgressHUD($isLoading, config: GameNetApp.hudConfig)
//        )
        .onChange(of: viewModel.state) { _, state in
            isLoading = state == .loading
        }
        .task {
            await viewModel.fetchData()
        }
    }
}

#Preview {
    ServerDrivenDashboardView(viewModel: ServerDrivenDashboardViewModel())
}
