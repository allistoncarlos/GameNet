//
//  PlatformItemView.swift
//  GameNet
//

import CachedAsyncImage
import SwiftUI

struct PlatformItemView: View {
    var name: String
    var imageURL: URL?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondary.opacity(0.12))

            CachedAsyncImage(url: imageURL) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(10)
                case .failure:
                    Image(systemName: "laptopcomputer")
                        .font(.title)
                        .foregroundStyle(.secondary)
                case .empty:
                    ProgressView()
                        .progressViewStyle(.circular)
                @unknown default:
                    EmptyView()
                }
            }

            Text(name)
                .padding(4)
                .foregroundColor(.white)
                .font(.system(size: 10))
                .gameNetGlassEffect()
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
