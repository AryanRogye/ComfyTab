//
//  LiquidGlassParameters.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/16/25.
//


import SwiftUI

struct LiquidGlassParameters {
//    var glassColor: Color = .white.opacity(0.35)
//    var lightIntensity: Float = 1.2
//    var ambientStrength: Float = 0.15
//    var thickness: Float = 12.0
//    var refractiveIndex: Float = 1.3
//    var blurRadius: Float = 1.8
//    var chromaticAberration: Float = 0.0
    
//    var glassColor: Color      = .white.opacity(0.45)
//    var lightIntensity: Float  = 1.8
//    var ambientStrength: Float = 0.22
//    var thickness: Float       = 16.0
//    var refractiveIndex: Float = 1.38
//    var blurRadius: Float      = 2.2
//    var chromaticAberration: Float = 0.015
    
    var glassColor: Color      = .white.opacity(0.45)
    var lightIntensity: Float  = 3
    var ambientStrength: Float = 0.22
    var thickness: Float       = 16.0
    var refractiveIndex: Float = 2.0
    var blurRadius: Float      = 2.2
    var chromaticAberration: Float = 0.015

    var lightAngle: Float = .pi / 3
    var isRefractionEnabled: Bool = true
    var isLightingEnabled: Bool = true
    var isGlassColorEnabled: Bool = true
    var isBlurEnabled: Bool = true
}

