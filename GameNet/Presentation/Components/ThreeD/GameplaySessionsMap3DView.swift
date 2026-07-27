//
//  GameplaySessionsMap3DView.swift
//  GameNet
//
//  Mapa 3D de sessões de um jogo: altura = duração, posição = ordem temporal.
//

import SceneKit
import SwiftUI

struct GameplaySessionsMap3DView: View {
    let sessions: [GameplaySession]
    var accentColor: Color = .main
    var isActiveSession: ((GameplaySession) -> Bool)?

    @State private var selectedSessionId: String?

    private var selectedSession: GameplaySession? {
        sessions.first { ($0.id ?? "") == selectedSessionId }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mapa de Sessões")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)

            #if os(iOS)
            GameplaySessionsMapSceneView(
                sessions: sessions,
                accent: UIColor(accentColor),
                selectedSessionId: $selectedSessionId,
                isActiveSession: isActiveSession
            )
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            #else
            Text("Visualização 3D disponível no iOS")
                .frame(height: 200)
            #endif

            if let selectedSession {
                VStack(alignment: .leading, spacing: 4) {
                    if selectedSession.finish == nil {
                        Text("Em andamento")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.green)
                    }
                    Text(selectedSession.start.toFormattedString(dateFormat: GameNetApp.dateTimeFormat))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if selectedSession.finish != nil {
                        Text(selectedSession.totalGameplayTime)
                            .font(.caption.weight(.semibold))
                    }
                }
            } else {
                Text("Toque em um bloco para ver a sessão")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#if os(iOS)
struct GameplaySessionsMapSceneView: UIViewRepresentable {
    let sessions: [GameplaySession]
    let accent: UIColor
    @Binding var selectedSessionId: String?
    var isActiveSession: ((GameplaySession) -> Bool)?

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        scnView.isOpaque = false
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true
        scnView.defaultCameraController.interactionMode = .orbitTurntable
        scnView.preferredFramesPerSecond = 60

        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        scnView.addGestureRecognizer(tap)
        context.coordinator.scnView = scnView
        scnView.scene = makeScene()
        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = makeScene()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(selectedSessionId: $selectedSessionId)
    }

    private func makeScene() -> SCNScene {
        let scene = SCNScene()

        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.position = SCNVector3(0, 3, 7)
        camera.look(at: SCNVector3(0, 0.8, 0))
        scene.rootNode.addChildNode(camera)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 300
        scene.rootNode.addChildNode(ambient)

        let key = SCNNode()
        key.light = SCNLight()
        key.light?.type = .directional
        key.light?.intensity = 900
        key.eulerAngles = SCNVector3(-0.8, 0.3, 0)
        scene.rootNode.addChildNode(key)

        let chronological = sessions.sorted { $0.start < $1.start }
        let durations = chronological.map { durationMinutes(for: $0) }
        let maxDuration = max(durations.max() ?? 1, 1)

        let columns = min(8, max(chronological.count, 1))
        for (index, session) in chronological.enumerated() {
            let row = index / columns
            let col = index % columns
            let x = Float(col) * 0.7 - Float(columns - 1) * 0.35
            let z = -Float(row) * 0.8
            let minutes = durations[index]
            let height = max(0.2, Float(minutes / maxDuration) * 2.5)

            let box = SCNBox(width: 0.45, height: CGFloat(height), length: 0.45, chamferRadius: 0.04)
            let material = SCNMaterial()
            let active = isActiveSession?(session) == true || session.finish == nil
            material.diffuse.contents = active ? UIColor.systemGreen : accent
            material.lightingModel = .physicallyBased
            material.roughness.contents = 0.5
            if active {
                material.emission.contents = UIColor.systemGreen.withAlphaComponent(0.35)
            }
            box.materials = [material]

            let node = SCNNode(geometry: box)
            node.position = SCNVector3(x, height / 2, z)
            node.name = session.id ?? "session-\(index)"
            scene.rootNode.addChildNode(node)

            if active {
                let pulse = SCNAction.repeatForever(
                    .sequence([
                        .customAction(duration: 0.8) { node, elapsed in
                            let t = Float(elapsed / 0.8)
                            let opacity = 0.55 + 0.45 * sin(t * .pi)
                            node.geometry?.firstMaterial?.emission.intensity = CGFloat(opacity)
                        },
                        .customAction(duration: 0.8) { node, elapsed in
                            let t = Float(elapsed / 0.8)
                            let opacity = 0.55 + 0.45 * sin((1 - t) * .pi)
                            node.geometry?.firstMaterial?.emission.intensity = CGFloat(opacity)
                        }
                    ])
                )
                node.runAction(pulse)
            }
        }

        return scene
    }

    private func durationMinutes(for session: GameplaySession) -> Double {
        let end = session.finish ?? Date()
        return max(end.timeIntervalSince(session.start) / 60.0, 1)
    }

    final class Coordinator: NSObject {
        var selectedSessionId: Binding<String?>
        weak var scnView: SCNView?

        init(selectedSessionId: Binding<String?>) {
            self.selectedSessionId = selectedSessionId
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let scnView else { return }
            let hits = scnView.hitTest(gesture.location(in: scnView), options: nil)
            guard let name = hits.first?.node.name else { return }
            selectedSessionId.wrappedValue = name
        }
    }
}
#endif
