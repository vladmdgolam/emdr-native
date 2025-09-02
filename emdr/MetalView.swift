import SwiftUI
import MetalKit

struct MetalView: UIViewRepresentable {
    var speed: Float = 400 // points/sec
    var dotRadius: Float = 20
    var color: SIMD4<Float> = SIMD4<Float>(1, 1, 1, 1)

    func makeUIView(context: Context) -> MTKView {
        let view = MTKView()
        view.colorPixelFormat = .bgra8Unorm

        if let renderer = MetalRenderer(mtkView: view) {
            context.coordinator.renderer = renderer
            renderer.setSpeed(pointsPerSecond: speed)
            renderer.setRadius(points: dotRadius)
            renderer.setColor(color)
        }
        return view
    }

    func updateUIView(_ uiView: MTKView, context: Context) {
        if let renderer = context.coordinator.renderer {
            renderer.setSpeed(pointsPerSecond: speed)
            renderer.setRadius(points: dotRadius)
            renderer.setColor(color)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        var renderer: MetalRenderer?
    }
}

