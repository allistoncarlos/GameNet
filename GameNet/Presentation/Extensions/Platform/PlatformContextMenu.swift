//
//  PlatformContextMenu.swift
//  GameNet
//

import SwiftUI

#if os(macOS)
import AppKit
#endif

extension View {
    /// Long-press on iOS/iPadOS and right-click (or Control+click) on macOS.
    @ViewBuilder
    func gameNetPointerContextMenu<MenuContent: View>(
        isPresented: Binding<Bool>,
        onPointerMenu: @escaping () -> Void,
        @ViewBuilder menu: @escaping () -> MenuContent
    ) -> some View {
        let shapedContent = self
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())

        #if os(macOS)
        shapedContent
            .overlay {
                MacRightClickCaptureView(onRightClick: onPointerMenu)
            }
            .popover(isPresented: isPresented, arrowEdge: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    menu()
                }
                .padding(8)
            }
        #else
        shapedContent
            .contextMenu(menuItems: menu)
        #endif
    }
}

#if os(macOS)
private struct MacRightClickCaptureView: NSViewRepresentable {
    let onRightClick: () -> Void

    func makeNSView(context: Context) -> RightClickCaptureNSView {
        let view = RightClickCaptureNSView()
        view.onRightClick = onRightClick
        return view
    }

    func updateNSView(_ nsView: RightClickCaptureNSView, context: Context) {
        nsView.onRightClick = onRightClick
    }
}

private final class RightClickCaptureNSView: NSView {
    var onRightClick: (() -> Void)?

    override func hitTest(_ point: NSPoint) -> NSView? {
        guard let event = NSApp.currentEvent else {
            return nil
        }

        switch event.type {
        case .rightMouseDown:
            return self
        case .leftMouseDown where event.modifierFlags.contains(.control):
            return self
        default:
            return nil
        }
    }

    override func rightMouseDown(with event: NSEvent) {
        onRightClick?()
    }

    override func mouseDown(with event: NSEvent) {
        if event.modifierFlags.contains(.control) {
            onRightClick?()
        }
    }
}
#endif
