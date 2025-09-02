import Foundation
import Metal
import MetalKit
import simd

struct RendererUniforms {
    var resolution: SIMD2<Float>
    var time: Float
    var radius: Float
    var color: SIMD4<Float>
    var speed: Float
    var safeInsets: SIMD4<Float> // left, right, top, bottom
}

final class MetalRenderer: NSObject, MTKViewDelegate {
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLRenderPipelineState

    private var startTime: CFTimeInterval = CACurrentMediaTime()
    private var accumulatedTime: CFTimeInterval = 0
    private var isPaused: Bool = false
    private var uniforms = RendererUniforms(
        resolution: .zero,
        time: 0,
        radius: 20,
        color: SIMD4<Float>(1, 1, 1, 1),
        speed: 400, // points per second
        safeInsets: .zero
    )

    init?(mtkView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue(),
              let library = try? device.makeDefaultLibrary()
        else { return nil }

        self.device = device
        self.commandQueue = commandQueue

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_passthrough")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_dot")

        do {
            self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            return nil
        }

        super.init()

        mtkView.device = device
        mtkView.delegate = self
        mtkView.clearColor = MTLClearColorMake(0, 0, 0, 1)
        mtkView.isPaused = false
        mtkView.enableSetNeedsDisplay = false
        mtkView.preferredFramesPerSecond = 60
        mtkView.framebufferOnly = true
    }

    // Public knobs
    func setSpeed(pointsPerSecond: Float) { uniforms.speed = pointsPerSecond }
    func setRadius(points: Float) { uniforms.radius = points }
    func setColor(_ color: SIMD4<Float>) { uniforms.color = color }
    func setSafeAreaInsets(left: Float, right: Float, top: Float, bottom: Float) {
        uniforms.safeInsets = SIMD4<Float>(left, right, top, bottom)
    }
    func setPaused(_ paused: Bool) {
        if paused != isPaused {
            if paused {
                // Freeze time at current accumulated value
                accumulatedTime = CACurrentMediaTime() - startTime
            } else {
                // Resume: reset start time so accumulated time continues
                startTime = CACurrentMediaTime() - accumulatedTime
            }
            isPaused = paused
        }
    }

    // MARK: - MTKViewDelegate
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        uniforms.resolution = SIMD2<Float>(Float(size.width), Float(size.height))
        // Reset start time so speed change appears immediate on orientation change
        startTime = CACurrentMediaTime() - accumulatedTime
    }

    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        else { return }

        let now = CACurrentMediaTime()
        if isPaused {
            // Keep uniforms.time constant while paused
            uniforms.time = Float(accumulatedTime)
        } else {
            uniforms.time = Float(now - startTime)
        }

        encoder.setRenderPipelineState(pipelineState)
        encoder.setFragmentBytes(&uniforms, length: MemoryLayout<RendererUniforms>.stride, index: 0)

        // Full-screen triangle (vertex shader generates positions)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)

        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
