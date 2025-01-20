//
//  Carousel.swift
//  GameNet
//
//  Created by Alliston Aleixo on 11/12/24.
//

import SwiftUI
import CachedAsyncImage

struct Carousel: View {
    var elements: [Element]
    
    var body: some View {
        ScrollView(.horizontal) {
            VStack(alignment: .leading, spacing: 15) {
                LazyHStack {
                    renderChildren(components: elements)
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    Carousel(
        elements: [
            Element(
                id: "element1",
                componentType: "CarouselCover",
                properties: .init(
                    id: "1",
                    title: "The Legend of Zelda: Breath of the Wild",
                    value: "01/01/2024 10:00",
                    url: "https://assets.reedpopcdn.com/148430785862.jpg/BROK/resize/1920x1920%3E/format/jpg/quality/80/148430785862.jpg"
                )
            ),
            Element(
                id: "element2",
                componentType: "CarouselCover",
                properties: .init(
                    id: "2",
                    title: "The Legend of Zelda: Tears of the Kingdom",
                    value: "02/01/2024 10:00",
                    url: "https://images.nintendolife.com/da314926e706f/switch-tloz-totk-boxart-011.large.jpg"
                )
            ),
        ]
    )
}
