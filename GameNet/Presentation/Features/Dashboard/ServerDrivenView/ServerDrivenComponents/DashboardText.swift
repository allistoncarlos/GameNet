//
//  DashboardText.swift
//  GameNet
//
//  Created by Alliston Aleixo on 25/11/24.
//

import SwiftUI

struct DashboardText: View {
    private var value: String
    
    init(_ value: String) {
        self.value = value
    }
    
    var body: some View {
        Text(value)
            .font(.dashboardGameTitle)
    }
}
