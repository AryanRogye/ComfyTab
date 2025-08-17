//
//  Color.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/17/25.
//

import AppKit
import SwiftUI

extension Color {
    func rgbaFloat4() -> SIMD4<Float> {
        let c = NSColor(self).usingColorSpace(.deviceRGB) ?? .white.withAlphaComponent(0.35)
        return .init(Float(c.redComponent), Float(c.greenComponent), Float(c.blueComponent), Float(c.alphaComponent))
    }
}
