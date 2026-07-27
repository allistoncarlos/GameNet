//
//  PlatformsIslands3DView.swift
//  GameNet
//
//  Distribuição de jogos por plataforma como "ilhas" 3D (Metal/SceneKit).
//

import SceneKit
import SwiftUI

struct PlatformsIslands3DView: View {
    let platforms: [PlatformGame]
    var total: Int

    @State private var selectedPlatformId: String?

    private var selectedPlatform: PlatformGame? {
        platforms.first { ($0.id ?? $0.name) == selectedPlatformId }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.tertiaryCardBackground)

            VStack(alignment: .leading, spacing: 12) {
                Text("Jogos por Plataforma")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.cardTitle)

                Text("\(total) jogos no total")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                #if os(iOS)
                PlatformsIslandsSceneView(
                    platforms: platforms,
                    selectedPlatformId: $selectedPlatformId
                )
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                #else
                Text("Visualização 3D disponível no iOS")
                    .frame(height: 240)
                #endif

                if let selectedPlatform {
                    HStack {
                        Text(selectedPlatform.name)
                            .font(.headline)
                        Spacer()
                        Text("\(selectedPlatform.platformGamesTotal)")
                            .font(.headline)
                    }
                } else {
                    Text("Toque em uma ilha para ver a plataforma")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .padding()
    }
}

#if os(iOS)
struct PlatformsIslandsSceneView: UIViewRepresentable {
    let platforms: [PlatformGame]
    @Binding var selectedPlatformId: String?

    private let palette: [UIColor] = [
        .systemTeal, .systemIndigo, .systemOrange, .systemPink,
        .systemGreen, .systemPurple, .systemBlue, .systemYellow
    ]

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
        Coordinator(selectedPlatformId: $selectedPlatformId)
    }

    private func makeScene() -> SCNScene {
        let scene = SCNScene()

        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.position = SCNVector3(0, 5, 8)
        camera.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(camera)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 280
        scene.rootNode.addChildNode(ambient)

        let key = SCNNode()
        key.light = SCNLight()
        key.light?.type = .directional
        key.light?.intensity = 950
        key.eulerAngles = SCNVector3(-0.9, 0.4, 0)
        scene.rootNode.addChildNode(key)

        let water = SCNPlane(width: 12, height: 12)
        let waterMaterial = SCNMaterial()
        waterMaterial.diffuse.contents = UIColor.systemBlue.withAlphaComponent(0.25)
        waterMaterial.isDoubleSided = true
        water.materials = [waterMaterial]
        let waterNode = SCNNode(geometry: water)
        waterNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
        waterNode.position = SCNVector3(0, -0.05, 0)
        scene.rootNode.addChildNode(waterNode)

        let maxTotal = max(platforms.map(\.platformGamesTotal).max() ?? 1, 1)
        let count = max(platforms.count, 1)

        for (index, platform) in platforms.enumerated() {
            let angle = Float(index) / Float(count) * Float.pi * 2
            let radius: Float = 2.4
            let x = cos(angle) * radius
            let z = sin(angle) * radius
            let height = max(0.35, Float(platform.platformGamesTotal) / Float(maxTotal) * 2.8)
            let islandRadius = 0.35 + Float(platform.platformGamesTotal) / Float(maxTotal) * 0.35

            let cylinder = SCNCylinder(radius: CGFloat(islandRadius), height: CGFloat(height))
            let material = SCNMaterial()
            material.diffuse.contents = palette[index % palette.count]
            material.lightingModel = .physicallyBased
            material.roughness.contents = 0.55
            material.metalness.contents = 0.1
            cylinder.materials = [material]

            let node = SCNNode(geometry: cylinder)
            node.position = SCNVector3(x, height / 2, z)
            node.name = platform.id ?? platform.name
            scene.rootNode.addChildNode(node)

            // Soft physics-like idle sway
            let sway = SCNAction.repeatForever(
                .sequence([
                    .moveBy(x: 0.04, y: 0, z: -0.03, duration: 1.4),
                    .moveBy(x: -0.04, y: 0, z: 0.03, duration: 1.4)
                ])
            )
            node.runAction(sway)
        }

        return scene
    }

    final class Coordinator: NSObject {
        var selectedPlatformId: Binding<String?>
        weak var scnView: SCNView?

        init(selectedPlatformId: Binding<String?>) {
            self.selectedPlatformId = selectedPlatformId
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let scnView else { return }
            let hits = scnView.hitTest(gesture.location(in: scnView), options: nil)
            guard let name = hits.first?.node.name else { return }
            selectedPlatformId.wrappedValue = name
            hits.first?.node.runAction(.sequence([
                .scale(to: 1.15, duration: 0.1),
                .scale(to: 1.0, duration: 0.12)
            ]))
        }
    }
}
#endif
