//
//  Subtitle.swift
//  GameNet
//
//  Created by Alliston Aleixo on 10/12/24.
//

import SwiftUI

struct Subtitle: View {
    private var value: String
    
    init(_ value: String) {
        self.value = value
    }
    
    var body: some View {
        Text(value)
            .font(.dashboardGameSubtitle)
    }
}
