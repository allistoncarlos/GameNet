//
//  YearTimeline3DView.swift
//  GameNet
//
//  Timeline 3D de totais anuais (finalizados/comprados), Metal via SceneKit.
//

import SceneKit
import SwiftUI

struct YearTimelineEntry: Identifiable, Hashable {
    let year: Int
    let primaryValue: Double
    let secondaryLabel: String?

    var id: Int { year }
}

struct YearTimeline3DView: View {
    let title: String
    let entries: [YearTimelineEntry]
    var accentColor: Color = .main
    var onSelectYear: (Int) -> Void

    @State private var selectedYear: Int?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.tertiaryCardBackground)

            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.cardTitle)

                #if os(iOS)
                YearTimelineSceneView(
                    entries: entries,
                    accent: UIColor(accentColor),
                    selectedYear: $selectedYear
                )
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                #else
                Text("Visualização 3D disponível no iOS")
                    .frame(height: 220)
                #endif

                if let selectedYear,
                   let entry = entries.first(where: { $0.year == selectedYear }) {
                    HStack {
                        Text(String(entry.year))
                            .font(.headline)
                        Spacer()
                        Text(formatted(entry.primaryValue))
                            .font(.headline)
                        if let secondary = entry.secondaryLabel {
                            Text(secondary)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button("Ver detalhes de \(entry.year)") {
                        onSelectYear(entry.year)
                    }
                    .font(.footnote)
                } else {
                    Text("Gire • toque em um anel/coluna do ano")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .padding()
    }

    private func formatted(_ value: Double) -> String {
        if value == floor(value) {
            return String(Int(value))
        }
        return String(format: "%.0f", value)
    }
}

#if os(iOS)
struct YearTimelineSceneView: UIViewRepresentable {
    let entries: [YearTimelineEntry]
    let accent: UIColor
    @Binding var selectedYear: Int?

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
        Coordinator(selectedYear: $selectedYear)
    }

    private func makeScene() -> SCNScene {
        let scene = SCNScene()

        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.position = SCNVector3(0, 3.5, 7)
        camera.look(at: SCNVector3(0, 0.5, 0))
        scene.rootNode.addChildNode(camera)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 320
        scene.rootNode.addChildNode(ambient)

        let key = SCNNode()
        key.light = SCNLight()
        key.light?.type = .directional
        key.light?.intensity = 900
        key.eulerAngles = SCNVector3(-0.7, 0.35, 0)
        scene.rootNode.addChildNode(key)

        let maxValue = max(entries.map(\.primaryValue).max() ?? 1, 1)
        let sorted = entries.sorted { $0.year < $1.year }

        for (index, entry) in sorted.enumerated() {
            let z = Float(index) * 1.15 - Float(sorted.count - 1) * 0.575
            let height = max(0.35, Float(entry.primaryValue / maxValue) * 2.4)
            let radius: CGFloat = 0.45

            let tube = SCNTube(innerRadius: radius * 0.55, outerRadius: radius, height: CGFloat(height))
            let material = SCNMaterial()
            material.diffuse.contents = accent.withAlphaComponent(0.85)
            material.lightingModel = .physicallyBased
            material.roughness.contents = 0.45
            material.metalness.contents = 0.2
            tube.materials = [material]

            let node = SCNNode(geometry: tube)
            node.position = SCNVector3(0, height / 2, z)
            node.name = "year-\(entry.year)"
            scene.rootNode.addChildNode(node)

            let label = SCNText(string: String(entry.year), extrusionDepth: 0.02)
            label.font = UIFont.systemFont(ofSize: 0.28, weight: .semibold)
            label.flatness = 0.1
            let labelNode = SCNNode(geometry: label)
            labelNode.scale = SCNVector3(0.6, 0.6, 0.6)
            labelNode.position = SCNVector3(-0.45, -0.15, z)
            labelNode.name = "year-\(entry.year)"
            scene.rootNode.addChildNode(labelNode)
        }

        let axis = SCNCylinder(radius: 0.02, height: CGFloat(max(sorted.count, 1)) * 1.2)
        let axisMaterial = SCNMaterial()
        axisMaterial.diffuse.contents = UIColor.white.withAlphaComponent(0.25)
        axis.materials = [axisMaterial]
        let axisNode = SCNNode(geometry: axis)
        axisNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        axisNode.position = SCNVector3(0, 0.02, 0)
        scene.rootNode.addChildNode(axisNode)

        return scene
    }

    final class Coordinator: NSObject {
        var selectedYear: Binding<Int?>
        weak var scnView: SCNView?

        init(selectedYear: Binding<Int?>) {
            self.selectedYear = selectedYear
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let scnView else { return }
            let hits = scnView.hitTest(gesture.location(in: scnView), options: nil)
            guard let name = hits.first?.node.name,
                  name.hasPrefix("year-"),
                  let year = Int(name.replacingOccurrences(of: "year-", with: "")) else {
                return
            }
            selectedYear.wrappedValue = year
            if let node = hits.first?.node {
                node.runAction(.sequence([
                    .scale(to: 1.12, duration: 0.1),
                    .scale(to: 1.0, duration: 0.1)
                ]))
            }
        }
    }
}
#endif
