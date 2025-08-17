//
//  CirclePiece.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/16/25.
//

import SwiftUI

struct CirclePiece: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var radius: CGFloat
    var thickness: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        let outerR = radius
        let innerR = radius - thickness
        
        // Outer arc
        path.addArc(center: center,
                    radius: outerR,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        
        // Inner arc (reverse)
        path.addArc(center: center,
                    radius: innerR,
                    startAngle: endAngle,
                    endAngle: startAngle,
                    clockwise: true)
        
        path.closeSubpath()
        return path
    }
}
