//
//  LiquidGlassBackground.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/17/25.
//

import SwiftUI
import Metal
import MetalKit

/// Parameters passed into the Liquid Glass shader.
/// Trimmed down for ComfyTab’s donut dial.
///
struct LiquidGlassBackground: NSViewRepresentable {
    var params = LiquidGlassParameters()
    func makeCoordinator() -> RenderCoordinator { RenderCoordinator() }
    
    func makeNSView(context: Context) -> some NSView {
        print("Making LiquidGlassBackground")
        let mtkView = MTKView()
        mtkView.device = MTLCreateSystemDefaultDevice()
        
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0)
        
        mtkView.framebufferOnly = false
        mtkView.isPaused = false
        mtkView.enableSetNeedsDisplay = false
        mtkView.preferredFramesPerSecond = 120
        
        context.coordinator.targetView = mtkView
        context.coordinator.setupMetal()
        
        mtkView.delegate = context.coordinator
        return mtkView
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        /// No need to pass it in, we dont change at runtime
        context.coordinator.params = params
    }
    
    class RenderCoordinator: NSObject, MTKViewDelegate {
        var targetView: MTKView!
        var params = LiquidGlassParameters()
        
        private var pipelineState: MTLRenderPipelineState!
        private var commandQueue: MTLCommandQueue!
        private var vertexBuffer: MTLBuffer!
        private var uniformBuffer: MTLBuffer!
        private var sampler: MTLSamplerState!
        private var bgTexture: MTLTexture!
        
        struct Uniforms {
            var size: SIMD2<Float>
            var glassColor: SIMD4<Float>
            var lightAngle: Float
            var lightIntensity: Float
            var ambient: Float
            var thickness: Float
            var refrIdx: Float
            var blurRadius: Float
            var chromAb: Float
            var flags: SIMD4<Float> // refraction, lighting, glassColor, blur
            
            // ring
            var center: SIMD2<Float>
            var outerRadius: Float
            var innerRadius: Float
        }
        
        func setupMetal() {
            let device = targetView.device!
            let library = device.makeDefaultLibrary()!
            
            bgTexture = makeSolidTexture(device: targetView.device!)
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = library.makeFunction(name: "fullscreenVertex")
            pipelineDescriptor.fragmentFunction = library.makeFunction(name: "liquidGlassFragment")
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            
            do {
                pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            } catch {
                print("Failed to create Pipline State With THe Liquid Glass Fragment':", error)
                pipelineState = nil
            }
            commandQueue = device.makeCommandQueue()
            let quad: [Float] = [
                -1,-1, 0,1,   1,-1, 1,1,   -1, 1, 0,0,
                 -1, 1, 0,0,   1,-1, 1,1,    1, 1, 1,0
            ]
            vertexBuffer  = device.makeBuffer(bytes: quad, length: quad.count*MemoryLayout<Float>.size, options: [])
            uniformBuffer = device.makeBuffer(length: MemoryLayout<Uniforms>.size, options: [])
            
            let s = MTLSamplerDescriptor()
            s.minFilter = .linear; s.magFilter = .linear; s.mipFilter = .notMipmapped
            sampler = device.makeSamplerState(descriptor: s)
        }
        
        func draw(in view: MTKView) {
            guard let rp = view.currentRenderPassDescriptor,
                  let drawable = view.currentDrawable,
                  let cmd = commandQueue.makeCommandBuffer(),
                  let enc = cmd.makeRenderCommandEncoder(descriptor: rp)
            else { return }
            
            let w = Float(view.drawableSize.width)
            let h = Float(view.drawableSize.height)
            let center = SIMD2<Float>(w * 0.5, h * 0.5)
            let outer = Float(min(w, h)) * 0.45
            let scale = Float(view.drawableSize.width) / Float(view.bounds.size.width)
            
            var U = Uniforms(
                size: .init(w, h),
                glassColor: params.glassColor.rgbaFloat4(),
                lightAngle: params.lightAngle,
                lightIntensity: params.lightIntensity,
                ambient: params.ambientStrength,
                thickness: params.thickness,
                refrIdx: params.refractiveIndex,
                blurRadius: params.blurRadius,
                chromAb: params.chromaticAberration,
                flags: .init(params.isRefractionEnabled ? 1:0,
                             params.isLightingEnabled ? 1:0,
                             params.isGlassColorEnabled ? 1:0,
                             params.isBlurEnabled ? 1:0),
                center: center,
                outerRadius: outer,
                innerRadius: max(outer - 20, 0) // tune to your donut thickness
            )
            memcpy(uniformBuffer.contents(), &U, MemoryLayout<Uniforms>.size)
            
            enc.setRenderPipelineState(pipelineState)
            enc.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            
            enc.setFragmentBuffer(uniformBuffer, offset: 0, index: 0)
            enc.setFragmentTexture(bgTexture, index: 0) // when you add a background
            enc.setFragmentSamplerState(sampler, index: 0)
            
            enc.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
            enc.endEncoding()
            cmd.present(drawable)
            cmd.commit()
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            
        }
        
        private func makeSolidTexture(device: MTLDevice,
                                      color: (r: UInt8,g: UInt8,b: UInt8,a: UInt8) = (255,255,255,255)) -> MTLTexture {
            let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                width: 1, height: 1, mipmapped: false)
            desc.usage = [.shaderRead]
            let tex = device.makeTexture(descriptor: desc)!
            var px = [color.b, color.g, color.r, color.a] // BGRA order
            tex.replace(region: MTLRegionMake2D(0, 0, 1, 1), mipmapLevel: 0,
                        withBytes: &px, bytesPerRow: 4)
            return tex
        }
    }
}
