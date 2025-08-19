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
        /// Used when animating the intro
        @Published public var visibleApps: [RunningApp] = []
        
        private var revealTask: Task<Void, Never>?
        private var isOverlayShowing: () -> Bool = { true }
        
        public func configure(isShowing: @escaping () -> Bool) {
            self.isOverlayShowing = isShowing
        }
        
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
        
        public func reset() {
            revealTask?.cancel()
            revealTask = nil
            visibleApps = []
            hoveringIndex = nil
        }
        
        
        func setVisibleAppsInstant(_ apps: [RunningApp]) {
            reset()
            visibleApps = apps
        }
        
        /// Function will add apps into the array, one by one, this simulates a nice animation
        public func addAppsOneByOne(
            apps: [RunningApp],
            perItemDelay: Duration = .milliseconds(100)
        ) {
            reset()
            revealTask = Task { [weak self] in
                guard let self else { return }
                for app in apps {
                    try? await Task.sleep(for: perItemDelay)
                    if Task.isCancelled || !self.isOverlayShowing() { return }
                    withAnimation(AppAnims.loadingAnimation) {
                        self.visibleApps.append(app)
                    }
                }
            }
        }
    }
}
