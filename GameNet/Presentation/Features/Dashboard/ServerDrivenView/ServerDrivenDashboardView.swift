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
            if let dynamicContainer = viewModel.dynamicContainer,
               let root = dynamicContainer.elements.first {
                let children = renderChildren(components: root.value)
                
                switch root.key {
                case Components.vstack.rawValue:
                    VStack {
                        children
                    }
                case Components.scrollView.rawValue:
                    ScrollView {
                        children
                    }
                default:
                    EmptyView()
                }
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

    @ViewBuilder
    func renderChildren(components: [String: Element]) -> some View {
        ForEach(Array(components.keys), id: \.self) { key in
            if let component = components[key] {
                switch key {
                case Components.text.rawValue:
                    if let value = component.value {
                        Title(value)
                    }
                
                case Components.image.rawValue:
                    if let url = component.url {
                        AsyncImage(url: url)
                    }
                default:
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    ServerDrivenDashboardView(viewModel: ServerDrivenDashboardViewModel())
}
