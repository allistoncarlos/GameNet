//
//  StoryShareActivityView.swift
//  GameNet
//

import SwiftUI

#if os(iOS)
import UIKit

/// Share sheet nativo usado como fallback do Instagram.
struct StoryShareActivityView: UIViewControllerRepresentable {
    let image: UIImage

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [image], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif
