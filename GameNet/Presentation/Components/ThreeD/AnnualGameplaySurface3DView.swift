//
//  AnnualGameplaySurface3DView.swift
//  GameNet
//
//  Superfície 3D do progresso anual de gameplay (Metal/SceneKit).
//  Eixos: dia do ano (X), minutos acumulados (Y), ano (Z).
//

import SceneKit
import SwiftUI

struct AnnualGameplaySurface3DView: View {
    let series: [AnnualGameplayProgressSeries]
    var onSelectYear: ((Int) -> Void)?

    @State private var selectedYear: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            #if os(iOS)
            AnnualGameplaySurfaceSceneView(
                series: series,
                selectedYear: $selectedYear
            )
            .frame(height: 260)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            #else
            Text("Visualização 3D disponível no iOS")
                .frame(height: 260)
            #endif

            if let selectedYear,
               let selected = series.first(where: { $0.year == selectedYear }) {
                HStack {
                    Text("Ano \(selected.year)")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("\(Int(selected.totalMinutes)) min")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let onSelectYear {
                    Button("Ver sessões de \(selected.year)") {
                        onSelectYear(selected.year)
                    }
                    .font(.footnote)
                }
            } else {
                Text("Gire a cena • toque em uma trilha para selecionar o ano")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#if os(iOS)
struct AnnualGameplaySurfaceSceneView: UIViewRepresentable {
    let series: [AnnualGameplayProgressSeries]
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
        camera.camera?.wantsHDR = true
        camera.position = SCNVector3(0, 4, 8)
        camera.look(at: SCNVector3(0, 1, 0))
        scene.rootNode.addChildNode(camera)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 300
        scene.rootNode.addChildNode(ambient)

        let key = SCNNode()
        key.light = SCNLight()
        key.light?.type = .directional
        key.light?.intensity = 850
        key.eulerAngles = SCNVector3(-0.9, 0.4, 0)
        scene.rootNode.addChildNode(key)

        let maxMinutes = max(series.map(\.totalMinutes).max() ?? 1, 1)
        let colors: [UIColor] = [
            .systemTeal, .systemIndigo, .systemOrange, .systemPink, .systemGreen, .systemPurple
        ]

        for (yearIndex, yearSeries) in series.enumerated() {
            let z = Float(yearIndex) * 1.1 - Float(series.count - 1) * 0.55
            let color = colors[yearIndex % colors.count]
            let sampled = samplePoints(yearSeries.points, stride: 3)

            guard sampled.count > 1 else { continue }

            var previous: SCNVector3?
            for point in sampled {
                let x = (Float(point.day) / 366.0) * 6.0 - 3.0
                let y = Float(point.cumulativeMinutes / maxMinutes) * 3.0
                let position = SCNVector3(x, y, z)

                if let previous {
                    let segment = makeSegment(from: previous, to: position, color: color)
                    segment.name = "year-\(yearSeries.year)"
                    scene.rootNode.addChildNode(segment)
                }
                previous = position
            }

            // End marker
            if let last = previous {
                let sphere = SCNSphere(radius: 0.08)
                let material = SCNMaterial()
                material.diffuse.contents = color
                sphere.materials = [material]
                let marker = SCNNode(geometry: sphere)
                marker.position = last
                marker.name = "year-\(yearSeries.year)"
                scene.rootNode.addChildNode(marker)
            }
        }

        // Base plane
        let base = SCNPlane(width: 7, height: Float(max(series.count, 1)) * 1.2)
        let baseMaterial = SCNMaterial()
        baseMaterial.diffuse.contents = UIColor(white: 0.14, alpha: 0.9)
        baseMaterial.isDoubleSided = true
        base.materials = [baseMaterial]
        let baseNode = SCNNode(geometry: base)
        baseNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
        baseNode.position = SCNVector3(0, 0, 0)
        scene.rootNode.addChildNode(baseNode)

        return scene
    }

    private func samplePoints(
        _ points: [AnnualGameplayProgressPoint],
        stride: Int
    ) -> [AnnualGameplayProgressPoint] {
        guard !points.isEmpty else { return [] }
        var result: [AnnualGameplayProgressPoint] = []
        for (index, point) in points.enumerated() where index % stride == 0 {
            result.append(point)
        }
        if let last = points.last, result.last?.id != last.id {
            result.append(last)
        }
        return result
    }

    private func makeSegment(from: SCNVector3, to: SCNVector3, color: UIColor) -> SCNNode {
        let vector = SCNVector3(to.x - from.x, to.y - from.y, to.z - from.z)
        let distance = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        let cylinder = SCNCylinder(radius: 0.025, height: CGFloat(distance))
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.lightingModel = .physicallyBased
        cylinder.materials = [material]

        let node = SCNNode(geometry: cylinder)
        node.position = SCNVector3(
            (from.x + to.x) / 2,
            (from.y + to.y) / 2,
            (from.z + to.z) / 2
        )
        node.look(at: to, up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 1, 0))
        return node
    }

    final class Coordinator: NSObject {
        var selectedYear: Binding<Int?>
        weak var scnView: SCNView?

        init(selectedYear: Binding<Int?>) {
            self.selectedYear = selectedYear
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let scnView else { return }
            let location = gesture.location(in: scnView)
            let hits = scnView.hitTest(location, options: nil)
            guard let name = hits.first?.node.name,
                  name.hasPrefix("year-"),
                  let year = Int(name.replacingOccurrences(of: "year-", with: "")) else {
                return
            }
            selectedYear.wrappedValue = year
        }
    }
}
#endif
