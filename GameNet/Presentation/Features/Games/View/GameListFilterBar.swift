//
//  GameListFilterBar.swift
//  GameNet
//

import SwiftUI

struct GameListFilterBar: View {
    @Binding var filter: GameListFilter
    var selectedPlatformCount: Int = 0
    var showsPlatformFilter: Bool = false
    var onPlatformFilterTap: (() -> Void)? = nil

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if showsPlatformFilter {
                    Button(action: { onPlatformFilterTap?() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "laptopcomputer")
                            Text(platformFilterTitle)
                        }
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundStyle(selectedPlatformCount > 0 ? Color.white : Color.primary)
                        .background(selectedPlatformCount > 0 ? Color.main : Color.secondary.opacity(0.18))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                ForEach(GameListFilter.allCases) { item in
                    Button {
                        filter = item
                    } label: {
                        Text(item.title)
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .foregroundStyle(filter == item ? Color.white : Color.primary)
                            .background(filter == item ? Color.main : Color.secondary.opacity(0.18))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var platformFilterTitle: String {
        if selectedPlatformCount == 0 {
            return "Plataformas"
        }

        return selectedPlatformCount == 1
            ? "1 plataforma"
            : "\(selectedPlatformCount) plataformas"
    }
}
