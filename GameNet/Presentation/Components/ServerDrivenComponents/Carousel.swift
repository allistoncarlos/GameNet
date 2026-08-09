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
