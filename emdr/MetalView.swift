import SwiftUI
import MetalKit

struct MetalView: UIViewRepresentable {
    var speed: Float = 400 // points/sec
    var dotRadius: Float = 20
    var color: SIMD4<Float> = SIMD4<Float>(1, 1, 1, 1)
    var paused: Bool = false
    var onTripleTap: (() -> Void)? = nil

    func makeUIView(context: Context) -> MTKView {
        let view = MTKView()
        view.colorPixelFormat = .bgra8Unorm

        if let renderer = MetalRenderer(mtkView: view) {
            context.coordinator.renderer = renderer
            renderer.setSpeed(pointsPerSecond: speed)
            renderer.setRadius(points: dotRadius)
            renderer.setColor(color)
            renderer.setPaused(paused)
            let insets = view.safeAreaInsets
            renderer.setSafeAreaInsets(left: Float(insets.left), right: Float(insets.right), top: Float(insets.top), bottom: Float(insets.bottom))
        }

        // Triple-finger tap recognizer
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTripleTap))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 3
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        return view
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        if let renderer = context.coordinator.renderer {
            renderer.setSpeed(pointsPerSecond: speed)
            renderer.setRadius(points: dotRadius)
            renderer.setColor(color)
            renderer.setPaused(paused)
            let insets = uiView.safeAreaInsets
            renderer.setSafeAreaInsets(left: Float(insets.left), right: Float(insets.right), top: Float(insets.top), bottom: Float(insets.bottom))
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(onTripleTap: onTripleTap) }

    final class Coordinator {
        var renderer: MetalRenderer?
        private let onTripleTap: (() -> Void)?

        init(onTripleTap: (() -> Void)? = nil) {
            self.onTripleTap = onTripleTap
        }

        @objc func handleTripleTap() {
            onTripleTap?()
        }
    }
}
