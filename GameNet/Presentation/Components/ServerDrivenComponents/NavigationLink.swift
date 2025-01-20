//
//  NavigationLink.swift
//  GameNet
//
//  Created by Alliston Aleixo on 10/12/24.
//

import SwiftUI

struct NavigationLink<Label>: View where Label : View {
    var value: any Hashable
    var label: () -> Label
    
    var body: some View {
        SwiftUI.NavigationLink(value: value) {
            label()
        }
    }
}

#Preview {
    NavigationLink(value: "properties") {
        Text("properties")
    }
}
