//
//  Card.swift
//  GameNet
//
//  Created by Alliston Aleixo on 25/11/24.
//

import SwiftUI

struct Card: View {
    var title: String?
    var color: Color
    
    var elements: [Element]?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(color)

            VStack(alignment: .leading, spacing: 15) {
                if let title {
                    VStack {
                        CardTitle(title)
                    }
                }

                VStack(alignment: .leading, spacing: 5) {
                    if let elements {
                        renderChildren(components: elements)
                    }
                }
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    Card(
        title: "Horas jogadas por ano",
        color: .secondaryCardBackground,
        elements: []
    )
}
