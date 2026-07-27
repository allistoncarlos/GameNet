//
//  Cover3DTransition.swift
//  GameNet
//
//  Transição 3D capa → detalhe: a caixa "levanta" e gira ao entrar no hero.
//

import SceneKit
import SwiftUI

enum Cover3DTransitionStyle {
    case none
    case liftAndTurn
}

struct Cover3DEntranceModifier: ViewModifier {
    let style: Cover3DTransitionStyle
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(appeared || style == .none ? 0 : 18),
                axis: (x: 0.15, y: 1, z: 0),
                anchor: .center,
                perspective: 0.55
            )
            .scaleEffect(appeared || style == .none ? 1 : 0.86)
            .offset(y: appeared || style == .none ? 0 : 24)
            .opacity(appeared || style == .none ? 1 : 0.0)
            .onAppear {
                guard style != .none else { return }
                withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                    appeared = true
                }
            }
            .onDisappear {
                appeared = false
            }
    }
}

extension View {
    /// Aplica a transição 3D de entrada da capa no detalhe do jogo.
    func cover3DEntrance(_ style: Cover3DTransitionStyle = .liftAndTurn) -> some View {
        modifier(Cover3DEntranceModifier(style: style))
    }
}

#if os(iOS)
/// Anima o nó da capa no SceneKit ao entrar na tela de detalhe.
enum Cover3DSceneTransition {
    static func playEntrance(on boxNode: SCNNode) {
        boxNode.eulerAngles = SCNVector3(0.35, 0.9, 0)
        boxNode.scale = SCNVector3(0.7, 0.7, 0.7)
        boxNode.position = SCNVector3(0, -0.35, 0)

        let rotate = SCNAction.rotateTo(
            x: 0.05,
            y: 0,
            z: 0,
            duration: 0.55,
            usesShortestUnitArc: true
        )
        let scale = SCNAction.scale(to: 1.0, duration: 0.55)
        let move = SCNAction.move(to: SCNVector3(0, 0, 0), duration: 0.55)
        rotate.timingMode = .easeOut
        scale.timingMode = .easeOut
        move.timingMode = .easeOut

        boxNode.runAction(.group([rotate, scale, move]))
    }
}
#endif
