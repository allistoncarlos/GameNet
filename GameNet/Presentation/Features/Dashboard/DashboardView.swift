//
//  DashboardView.swift
//  GameNet
//
//  Created by Alliston Aleixo on 03/08/22.
//

import SwiftUI

// MARK: - DashboardView

struct DashboardView: View {
    var body: some View {
        NavigationView {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .navigationBarTitle("Dashboard")
                .statusBarStyle(color: .main)
        }
    }
}

// MARK: - DashboardView_Previews

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) {
            DashboardView().preferredColorScheme($0)
        }
    }
}
