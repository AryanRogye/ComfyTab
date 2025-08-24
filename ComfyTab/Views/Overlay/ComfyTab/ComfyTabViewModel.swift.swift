//
//  ComfyTabViewModel.swift.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/19/25.
//

import SwiftUI
import Combine

extension ComfyTab {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        /// What index we're hovering on
        @Published public var hoveringIndex: Int? = nil
        
        /// Used for positioning of the lables
        public func labelPosition(
            startAngle: Angle,
            endAngle: Angle,
            radius: CGFloat,
            thickness: CGFloat,
            offset: CGFloat = 0
        ) -> CGPoint {
            let midAngle = (startAngle.radians + endAngle.radians) / 2
            let r = radius - (thickness / 2)
            let center = radius
            
            // offset pushes the label outward along the slice direction
            return CGPoint(
                x: center + cos(midAngle) * r + cos(midAngle) * offset,
                y: center + sin(midAngle) * r + sin(midAngle) * offset
            )
        }
    }
}
