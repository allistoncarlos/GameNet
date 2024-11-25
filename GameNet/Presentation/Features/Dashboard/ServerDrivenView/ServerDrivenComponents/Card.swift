//
//  Card.swift
//  GameNet
//
//  Created by Alliston Aleixo on 25/11/24.
//

import SwiftUI

struct Card: View {
    var title: String
    var color: Color
    
    var elements: [String: Element]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(color)

            VStack(alignment: .leading, spacing: 15) {
                VStack {
                    Title(title)
                }

                VStack(alignment: .leading, spacing: 5) {
                    renderChildren(components: elements)
                }
            }
            .padding()
        }
        .padding()
    }
}

// TODO: ISSO AQUI DEVE SER PARAMETRIZADO, TÁ DUPLICADO PRA TESTE
@ViewBuilder
func renderChildren(components: [String: Element]) -> some View {
    ForEach(Array(components.keys), id: \.self) { key in
        if let component = components[key] {
            switch key {
            case Components.text.rawValue:
                if let value = component.value {
                    Text(value)
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

#Preview {
    Card(
        title: "Horas jogadas por ano",
        color: .blue,
        elements: [:]
    )
}
