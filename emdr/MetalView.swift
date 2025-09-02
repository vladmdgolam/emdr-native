import SwiftUI
import MetalKit

struct MetalView: UIViewRepresentable {
    var speed: Float = 400 // points/sec
    var dotRadius: Float = 20
    var color: SIMD4<Float> = SIMD4<Float>(1, 1, 1, 1)
    var paused: Bool = false
    var onTripleTap: (() -> Void)? = nil
    var onTap: (() -> Void)? = nil
    var onPanChanged: ((CGFloat) -> Void)? = nil
    var onPanEnded: (() -> Void)? = nil

    func makeUIView(context: Context) -> MTKView {
        let view = MTKView()
        view.colorPixelFormat = .bgra8Unorm

        if let renderer = MetalRenderer(mtkView: view) {
            context.coordinator.renderer = renderer
            renderer.setSpeed(pointsPerSecond: speed)
            renderer.setRadius(points: dotRadius)
            renderer.setColor(color)
            renderer.setPaused(paused)
        }

        // Triple-finger tap recognizer
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTripleTap))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 3
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        // Single-finger tap recognizer (pause/resume)
        let singleTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleSingleTap))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        singleTap.cancelsTouchesInView = false
        view.addGestureRecognizer(singleTap)

        // Vertical pan recognizer for speed adjustment
        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = 1
        pan.cancelsTouchesInView = false
        view.addGestureRecognizer(pan)
        return view
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        if let renderer = context.coordinator.renderer {
            renderer.setSpeed(pointsPerSecond: speed)
            renderer.setRadius(points: dotRadius)
            renderer.setColor(color)
            renderer.setPaused(paused)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(onTripleTap: onTripleTap, onTap: onTap, onPanChanged: onPanChanged, onPanEnded: onPanEnded) }

    final class Coordinator: NSObject {
        var renderer: MetalRenderer?
        private let onTripleTap: (() -> Void)?
        private let onTap: (() -> Void)?
        private let onPanChanged: ((CGFloat) -> Void)?
        private let onPanEnded: (() -> Void)?
        private var lastPanY: CGFloat = 0

        init(onTripleTap: (() -> Void)? = nil, onTap: (() -> Void)? = nil, onPanChanged: ((CGFloat) -> Void)? = nil, onPanEnded: (() -> Void)? = nil) {
            self.onTripleTap = onTripleTap
            self.onTap = onTap
            self.onPanChanged = onPanChanged
            self.onPanEnded = onPanEnded
        }

        @objc func handleTripleTap() {
            onTripleTap?()
        }

        @objc func handleSingleTap() {
            onTap?()
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            switch gesture.state {
            case .began:
                lastPanY = 0
            case .changed:
                let translation = gesture.translation(in: gesture.view)
                let dy = translation.y
                let delta = dy - lastPanY
                lastPanY = dy
                onPanChanged?(delta)
            case .ended, .cancelled, .failed:
                onPanEnded?()
                lastPanY = 0
            default:
                break
            }
        }
    }
}
