//
//  Ring.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/17/25.
//

import SwiftUI

struct RingMask: Shape {
    var radius: CGFloat
    var thickness: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let outer = radius
        let inner = max(radius - thickness, 0)
        var p = Path()
        p.addArc(center: c, radius: outer, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
        p.addArc(center: c, radius: inner, startAngle: .degrees(360), endAngle: .degrees(0), clockwise: true)
        p.closeSubpath()
        return p
    }
}
