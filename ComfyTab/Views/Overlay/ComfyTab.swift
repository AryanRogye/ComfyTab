//
//  ComfyTab.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/15/25.
//

import SwiftUI


/// Donut Shaped
struct ComfyTab: View {
    
    @EnvironmentObject var viewModel: OverlayViewModel
    /// What index we're hovering on
    @State private var hoveringIndex: Int? = nil
    
    private let iconSize: CGFloat           = 48
    private let distanceFromCenter: CGFloat = 130
    private let hoverPopOut: CGFloat        = 12
    private let angleOffset: CGFloat        = -.pi/2
    
    var body: some View {
        ZStack(alignment: .center) {
            /// Background
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .allowsHitTesting(false)
                .mask {
                    /// Shape
                    Circle()
                        .stroke(
                            Color.primary.opacity(0.4),
                            lineWidth: viewModel.comfyTabSize.thickness
                        )
                        .frame(
                            width: viewModel.comfyTabSize.radius * 2,
                            height: viewModel.comfyTabSize.radius * 2)
                }
            /// Actual Apps
            appsView
        }
        .onChange(of: viewModel.isShowing) { _, value in
            if value {
                viewModel.getRunningApps()
            }
        }
    }
    
    /// Looping through the Running Apps
    private var appsView: some View {
        ZStack {
            
            ForEach(Array(viewModel.runningApps.enumerated()), id: \.offset) { index, app in
                
                /// Easy for us to know if the index we're in is getting hovered on or not
                let hovered = (hoveringIndex == index)
                
                /// Show Each App
                appView(icon: app.icon, index: index)
                    .frame(width: iconSize, height: iconSize)
                    .contentShape(Circle())
                    .zIndex(hovered ? 1 : 0)
                    .position(positionFor(
                        index: index,
                        hovered: hovered
                    ))
            }
        }
        .frame(
            width: viewModel.comfyTabSize.radius * 2,
            height: viewModel.comfyTabSize.radius * 2
        )
    }
    
    /// Singular App View
    private func appView(icon: NSImage?, index: Int) -> some View {
        Button(action: {
            viewModel.focusApp(index: index)
        }) {
            Group {
                if let icon = icon {
                    Image(nsImage: icon)
                        .resizable()
                        .clipShape(Circle())
                } else {
                    Circle().fill(.gray)
                }
            }
        }
        .buttonStyle(.plain)
        .shadow(radius: 4)
        .contentShape(Circle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                hoveringIndex = hovering ? index : nil
            }
        }
    }
    
    private func positionFor(index: Int, hovered: Bool) -> CGPoint {
        let count = max(viewModel.runningApps.count, 1)
        let a = (CGFloat(index) / CGFloat(count)) * 2 * .pi + angleOffset
        
        let centerR = viewModel.comfyTabSize.radius
        let minR = iconSize / 2 + 8
        
        // Base distance exactly as set, clamped only to min
        let baseR = max(distanceFromCenter, minR)
        
        // Force outward pop
        let r = hovered ? baseR + hoverPopOut : baseR
        
        return CGPoint(
            x: centerR + cos(a) * r,
            y: centerR + sin(a) * r
        )
    }
}

#Preview {
    
    let overlayViewModel = OverlayViewModel(runningAppManager: RunningAppManager())
    
    ComfyTab()
        .environmentObject(overlayViewModel)
        .task {
            overlayViewModel.getRunningApps()
        }
}
