//
//  GamePlatformFilterSheet.swift
//  GameNet
//

import SwiftUI

struct GamePlatformFilterSheet: View {
    let platforms: [Platform]
    @Binding var selectedPlatformIds: Set<String>

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            SwiftUI.List {
                ForEach(platforms.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }, id: \.id) { platform in
                    if let platformId = platform.id {
                        Button {
                            toggle(platformId)
                        } label: {
                            HStack {
                                Text(platform.name)
                                    .foregroundStyle(Color.primary)
                                Spacer()
                                if selectedPlatformIds.contains(platformId) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.main)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Plataformas")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Limpar") {
                        selectedPlatformIds = []
                    }
                    .disabled(selectedPlatformIds.isEmpty)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func toggle(_ platformId: String) {
        if selectedPlatformIds.contains(platformId) {
            selectedPlatformIds.remove(platformId)
        } else {
            selectedPlatformIds.insert(platformId)
        }
    }
}
