//
//  SpatialLibraryView.swift
//  GameNet
//
//  Galeria espacial 3D da biblioteca: capas como tiles navegáveis
//  em profundidade, acelerada por Metal via SceneKit.
//

import SceneKit
import SwiftUI

// MARK: - SpatialLibraryItem

struct SpatialLibraryItem: Identifiable, Hashable {
    let id: String
    let name: String
    let coverURL: String
    let platform: String
}

// MARK: - SpatialLibraryView

struct SpatialLibraryView: View {
    let games: [SpatialLibraryItem]
    var onSelect: (SpatialLibraryItem) -> Void

    @State private var selectedPlatform: String = "Todas"
    @State private var selectedItemId: String?

    private var platforms: [String] {
        let names = Set(games.map(\.platform).filter { !$0.isEmpty })
        return ["Todas"] + names.sorted()
    }

    private var filteredGames: [SpatialLibraryItem] {
        if selectedPlatform == "Todas" {
            return games
        }
        return games.filter { $0.platform == selectedPlatform }
    }

    var body: some View {
        VStack(spacing: 12) {
            Picker("Plataforma", selection: $selectedPlatform) {
                ForEach(platforms, id: \.self) { platform in
                    Text(platform).tag(platform)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            #if os(iOS)
            SpatialLibrarySceneView(
                games: filteredGames,
                selectedItemId: $selectedItemId
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
            #else
            Text("Visualização 3D disponível no iOS")
                .foregroundStyle(.secondary)
            #endif

            if let selected = filteredGames.first(where: { $0.id == selectedItemId }) {
                VStack(spacing: 8) {
                    Text(selected.name)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    Text(selected.platform)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button("Abrir detalhes") {
                        onSelect(selected)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.bottom)
            } else {
                Text("Arraste para explorar • toque em uma capa")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
            }
        }
        .navigationTitle("Prateleira 3D")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - SceneKit view

#if os(iOS)
struct SpatialLibrarySceneView: UIViewRepresentable {
    let games: [SpatialLibraryItem]
    @Binding var selectedItemId: String?

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        scnView.isOpaque = false
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = true
        scnView.defaultCameraController.interactionMode = .orbitTurntable
        scnView.defaultCameraController.maximumVerticalAngle = 45
        scnView.defaultCameraController.minimumVerticalAngle = -10
        scnView.preferredFramesPerSecond = 60

        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        scnView.addGestureRecognizer(tap)
        context.coordinator.scnView = scnView

        scnView.scene = makeScene(games: games, coordinator: context.coordinator)
        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = makeScene(games: games, coordinator: context.coordinator)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(selectedItemId: $selectedItemId)
    }

    private func makeScene(games: [SpatialLibraryItem], coordinator: Coordinator) -> SCNScene {
        let scene = SCNScene()

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.wantsHDR = true
        cameraNode.position = SCNVector3(0, 1.2, 6)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 350
        scene.rootNode.addChildNode(ambient)

        let key = SCNNode()
        key.light = SCNLight()
        key.light?.type = .directional
        key.light?.intensity = 900
        key.eulerAngles = SCNVector3(-0.8, 0.3, 0)
        scene.rootNode.addChildNode(key)

        let columns = 5
        let spacingX: Float = 1.35
        let spacingZ: Float = 1.7
        let rows = max(1, Int(ceil(Double(games.count) / Double(columns))))

        for (index, game) in games.enumerated() {
            let row = index / columns
            let col = index % columns
            let x = Float(col) * spacingX - Float(columns - 1) * spacingX / 2
            let z = -Float(row) * spacingZ

            let plane = SCNPlane(width: 1.0, height: 1.45)
            plane.cornerRadius = 0.06
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.secondarySystemFill
            material.lightingModel = .physicallyBased
            material.roughness.contents = 0.6
            plane.materials = [material]

            let node = SCNNode(geometry: plane)
            node.name = game.id
            node.position = SCNVector3(x, 0, z)
            scene.rootNode.addChildNode(node)

            Task { @MainActor in
                if let image = await CoverImageLoader.image(from: game.coverURL) {
                    material.diffuse.contents = image
                }
            }
        }

        // Floor shelf
        let floor = SCNFloor()
        floor.reflectivity = 0.05
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIColor(white: 0.12, alpha: 1)
        floor.materials = [floorMaterial]
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(0, -0.8, -Float(rows) * spacingZ / 2)
        scene.rootNode.addChildNode(floorNode)

        coordinator.itemIds = Set(games.map(\.id))
        return scene
    }

    final class Coordinator: NSObject {
        var selectedItemId: Binding<String?>
        weak var scnView: SCNView?
        var itemIds: Set<String> = []

        init(selectedItemId: Binding<String?>) {
            self.selectedItemId = selectedItemId
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let scnView else { return }
            let location = gesture.location(in: scnView)
            let hits = scnView.hitTest(location, options: [.searchMode: SCNHitTestSearchMode.closest.rawValue])
            guard let name = hits.first?.node.name, itemIds.contains(name) else { return }
            selectedItemId.wrappedValue = name

            if let node = hits.first?.node {
                let pulse = SCNAction.sequence([
                    SCNAction.scale(to: 1.12, duration: 0.12),
                    SCNAction.scale(to: 1.0, duration: 0.12)
                ])
                node.runAction(pulse)
            }
        }
    }
}
#endif
