//
//  AsyncImage.swift
//  GameNet
//
//  Created by Alliston Aleixo on 24/11/24.
//

import SwiftUI
import CachedAsyncImage

struct AsyncImage: View {
    var url: String
    
    var body: some View {
        CachedAsyncImage(url: URL(string: url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: { ProgressView().progressViewStyle(.circular) }
    }
}
