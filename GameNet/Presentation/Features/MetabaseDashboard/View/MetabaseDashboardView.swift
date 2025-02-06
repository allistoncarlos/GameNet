//
//  MetabaseDashboardView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 19/12/24.
//

#if canImport(WebKit)
import SwiftUI

struct MetabaseDashboardView: View {
    @ObservedObject var viewModel: MetabaseDashboardViewModel
    @State var isLoading = true

    var body: some View {
        ZStack {
            WebView()
        }
        .navigationView(title: "Metabase")
    }
    
}

#Preview {
    MetabaseDashboardView(viewModel: MetabaseDashboardViewModel())
}
#endif
