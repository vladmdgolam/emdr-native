import SwiftUI

#if canImport(UIKit) && canImport(MetalKit)
import UIKit
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
    var safeAreaInsets: EdgeInsets = EdgeInsets()

    func makeUIView(context: Context) -> MTKView {
        let view = MTKView()
        view.colorPixelFormat = .bgra8Unorm

        if let renderer = MetalRenderer(mtkView: view) {
            context.coordinator.renderer = renderer
            renderer.setSpeed(pointsPerSecond: speed)
            renderer.setRadius(points: dotRadius)
            renderer.setColor(color)
            renderer.setPaused(paused)
            updateSafeArea(on: renderer, using: view)
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
            updateSafeArea(on: renderer, using: uiView)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(onTripleTap: onTripleTap, onTap: onTap, onPanChanged: onPanChanged, onPanEnded: onPanEnded) }

    private func updateSafeArea(on renderer: MetalRenderer, using view: MTKView) {
        let scale = view.window?.screen.scale ?? UIScreen.main.scale
        let left = Float(safeAreaInsets.leading) * Float(scale)
        let right = Float(safeAreaInsets.trailing) * Float(scale)
        let top = Float(safeAreaInsets.top) * Float(scale)
        let bottom = Float(safeAreaInsets.bottom) * Float(scale)
        renderer.setSafeAreaInsets(left: left, right: right, top: top, bottom: bottom)
    }

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

#elseif canImport(AppKit) && canImport(MetalKit) && !targetEnvironment(macCatalyst)
import AppKit
import MetalKit

struct MetalView: NSViewRepresentable {
    var speed: Float = 400 // points/sec
    var dotRadius: Float = 20
    var color: SIMD4<Float> = SIMD4<Float>(1, 1, 1, 1)
    var paused: Bool = false
    var onTripleTap: (() -> Void)? = nil
    var onTap: (() -> Void)? = nil
    var onPanChanged: ((CGFloat) -> Void)? = nil
    var onPanEnded: (() -> Void)? = nil
    var safeAreaInsets: EdgeInsets = EdgeInsets()

    func makeNSView(context: Context) -> MTKView {
        let view = MTKView()
        view.colorPixelFormat = .bgra8Unorm

        if let renderer = MetalRenderer(mtkView: view) {
            context.coordinator.renderer = renderer
            renderer.setSpeed(pointsPerSecond: speed)
            renderer.setRadius(points: dotRadius)
            renderer.setColor(color)
            renderer.setPaused(paused)
            updateSafeArea(on: renderer, using: view)
        }

        // Triple-click recognizer (macOS analogue to triple-finger tap)
        let tripleClick = NSClickGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTripleClick))
        tripleClick.numberOfClicksRequired = 3
        view.addGestureRecognizer(tripleClick)

        // Single click recognizer (pause/resume)
        let singleClick = NSClickGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleSingleClick))
        singleClick.numberOfClicksRequired = 1
        view.addGestureRecognizer(singleClick)

        // Pan recognizer for speed adjustment
        let pan = NSPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        view.addGestureRecognizer(pan)

        return view
    }

    func updateNSView(_ nsView: MTKView, context: Context) {
        if let renderer = context.coordinator.renderer {
            renderer.setSpeed(pointsPerSecond: speed)
            renderer.setRadius(points: dotRadius)
            renderer.setColor(color)
            renderer.setPaused(paused)
            updateSafeArea(on: renderer, using: nsView)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(onTripleTap: onTripleTap, onTap: onTap, onPanChanged: onPanChanged, onPanEnded: onPanEnded) }

    private func updateSafeArea(on renderer: MetalRenderer, using view: MTKView) {
        let scale = view.window?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 1.0
        let left = Float(safeAreaInsets.leading) * Float(scale)
        let right = Float(safeAreaInsets.trailing) * Float(scale)
        let top = Float(safeAreaInsets.top) * Float(scale)
        let bottom = Float(safeAreaInsets.bottom) * Float(scale)
        renderer.setSafeAreaInsets(left: left, right: right, top: top, bottom: bottom)
    }

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

        @objc func handleTripleClick() {
            onTripleTap?()
        }

        @objc func handleSingleClick() {
            onTap?()
        }

        @objc func handlePan(_ gesture: NSPanGestureRecognizer) {
            switch gesture.state {
            case .began:
                lastPanY = 0
            case .changed:
                let translation = gesture.translation(in: gesture.view)
                let dy = translation.y
                let delta = dy - lastPanY
                lastPanY = dy
                onPanChanged?(delta)
            case .ended, .cancelled:
                onPanEnded?()
                lastPanY = 0
            default:
                break
            }
        }
    }
}

#else

// Fallback for platforms where UIKit/MetalKit aren't available
struct MetalView: View {
    var speed: Float = 400 // points/sec
    var dotRadius: Float = 20
    var color: SIMD4<Float> = SIMD4<Float>(1, 1, 1, 1)
    var paused: Bool = false
    var onTripleTap: (() -> Void)? = nil
    var onTap: (() -> Void)? = nil
    var onPanChanged: ((CGFloat) -> Void)? = nil
    var onPanEnded: (() -> Void)? = nil
    var safeAreaInsets: EdgeInsets = EdgeInsets()

    var body: some View {
        Text("MetalView is not supported on this platform.")
            .foregroundStyle(.secondary)
    }
}

#endif
