//
//  GameCover3DView.swift
//  GameNet
//
//  Caa 3D (caixa/cartucho) acelerada por Metal via SceneKit,
//  com parallax leve pelo giroscópio.
//

import CoreMotion
import SceneKit
import SwiftUI

// MARK: - GameCover3DView

struct GameCover3DView: View {
    let coverURL: String
    var cornerRadius: CGFloat = 12
    var enablesMotion: Bool = true
    var autoRotate: Bool = false
    var playsEntranceTransition: Bool = false

    @State private var coverImage: UIImage?
    @State private var isLoading = true

    var body: some View {
        #if os(iOS)
        ZStack {
            GameCoverSceneKitView(
                coverImage: coverImage ?? CoverImageLoader.placeholder(),
                enablesMotion: enablesMotion,
                autoRotate: autoRotate,
                playsEntranceTransition: playsEntranceTransition
            )

            if isLoading {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.secondary.opacity(0.2))
                    .redacted(reason: .placeholder)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .cover3DEntrance(playsEntranceTransition ? .liftAndTurn : .none)
        .task(id: coverURL) {
            isLoading = true
            coverImage = await CoverImageLoader.image(from: coverURL)
            isLoading = false
        }
        #else
        CachedAsyncImageFallback(coverURL: coverURL, cornerRadius: cornerRadius)
        #endif
    }
}

#if !os(iOS)
import CachedAsyncImage

private struct CachedAsyncImageFallback: View {
    let coverURL: String
    let cornerRadius: CGFloat

    var body: some View {
        CachedAsyncImage(url: URL(string: coverURL)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            ProgressView()
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}
#endif

// MARK: - SceneKit bridge

#if os(iOS)
struct GameCoverSceneKitView: UIViewRepresentable {
    let coverImage: UIImage
    var enablesMotion: Bool
    var autoRotate: Bool

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = makeScene(coverImage: coverImage)
        scnView.backgroundColor = .clear
        scnView.isOpaque = false
        scnView.antialiasingMode = .multisampling4X
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = false
        scnView.preferredFramesPerSecond = 60

        context.coordinator.boxNode = scnView.scene?.rootNode.childNode(withName: "coverBox", recursively: false)
        context.coordinator.autoRotate = autoRotate

        if enablesMotion {
            context.coordinator.startMotion()
        } else if autoRotate {
            context.coordinator.startAutoRotate()
        }

        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        guard let box = uiView.scene?.rootNode.childNode(withName: "coverBox", recursively: false) else {
            return
        }

        applyCoverMaterial(to: box, image: coverImage)
        context.coordinator.boxNode = box
        context.coordinator.autoRotate = autoRotate
    }

    static func dismantleUIView(_ uiView: SCNView, coordinator: Coordinator) {
        coordinator.stop()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    // MARK: Scene

    private func makeScene(coverImage: UIImage) -> SCNScene {
        let scene = SCNScene()

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.wantsHDR = true
        cameraNode.position = SCNVector3(0, 0, 3.2)
        scene.rootNode.addChildNode(cameraNode)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 400
        scene.rootNode.addChildNode(ambient)

        let keyLight = SCNNode()
        keyLight.light = SCNLight()
        keyLight.light?.type = .directional
        keyLight.light?.intensity = 800
        keyLight.eulerAngles = SCNVector3(-0.6, 0.4, 0)
        scene.rootNode.addChildNode(keyLight)

        let box = SCNBox(width: 1.0, height: 1.5, length: 0.1, chamferRadius: 0.02)
        let boxNode = SCNNode(geometry: box)
        boxNode.name = "coverBox"
        applyCoverMaterial(to: boxNode, image: coverImage)
        scene.rootNode.addChildNode(boxNode)

        return scene
    }

    private func applyCoverMaterial(to node: SCNNode, image: UIImage) {
        guard let box = node.geometry as? SCNBox else { return }

        let front = SCNMaterial()
        front.diffuse.contents = image
        front.lightingModel = .physicallyBased
        front.roughness.contents = 0.55
        front.metalness.contents = 0.05

        let spine = SCNMaterial()
        spine.diffuse.contents = UIColor(white: 0.15, alpha: 1)
        spine.lightingModel = .physicallyBased
        spine.roughness.contents = 0.7

        let back = SCNMaterial()
        back.diffuse.contents = UIColor(white: 0.08, alpha: 1)
        back.lightingModel = .physicallyBased

        // SCNBox materials: front, right, back, left, top, bottom
        box.materials = [front, spine, back, spine, spine, spine]
    }

    // MARK: Coordinator

    final class Coordinator {
        var boxNode: SCNNode?
        var autoRotate = false
        private let motionManager = CMMotionManager()
        private var displayLink: CADisplayLink?
        private var autoAngle: Float = 0

        func startMotion() {
            guard motionManager.isDeviceMotionAvailable else {
                startAutoRotate()
                return
            }

            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
                guard let self, let motion, let boxNode else { return }
                let roll = Float(motion.attitude.roll) * 0.35
                let pitch = Float(motion.attitude.pitch) * 0.25
                boxNode.eulerAngles = SCNVector3(pitch, roll, 0)
            }
        }

        func startAutoRotate() {
            stopDisplayLink()
            let link = CADisplayLink(target: self, selector: #selector(tickAutoRotate))
            link.add(to: .main, forMode: .common)
            displayLink = link
        }

        @objc private func tickAutoRotate() {
            guard let boxNode else { return }
            autoAngle += 0.01
            boxNode.eulerAngles = SCNVector3(0.1, sin(autoAngle) * 0.35, 0)
        }

        func stop() {
            motionManager.stopDeviceMotionUpdates()
            stopDisplayLink()
        }

        private func stopDisplayLink() {
            displayLink?.invalidate()
            displayLink = nil
        }
    }
}
#endif
