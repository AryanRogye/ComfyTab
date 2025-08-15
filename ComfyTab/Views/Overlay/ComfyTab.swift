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
    
    var body: some View {
        ZStack(alignment: .center) {
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .mask {
                    Circle()
                        .stroke(
                            Color.primary.opacity(0.4),
                            lineWidth: viewModel.comfyTabSize.thickness
                        )
                        .frame(
                            width: viewModel.comfyTabSize.radius * 2,
                            height: viewModel.comfyTabSize.radius * 2)
                }
            appsView
        }
        .onChange(of: viewModel.isShowing) { _, value in
            if value {
                viewModel.getRunningApps()
            }
        }
    }
    
    private var appsView: some View {
        ZStack {
            ForEach(Array(viewModel.runningApps.enumerated()), id: \.offset) { index, app in
                appView(icon: app.icon)
                    .position(positionFor(index: index))
            }
        }
        .frame(
            width: viewModel.comfyTabSize.radius * 2,
            height: viewModel.comfyTabSize.radius * 2
        )
    }
    
    private func appView(icon: NSImage?) -> some View {
        VStack {
            if let icon = icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            } else {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 48, height: 48)
            }	
        }
    }
    
    func positionFor(index: Int) -> CGPoint {
        let r = viewModel.comfyTabSize.radius
        let a = CGFloat(index) / CGFloat(viewModel.runningApps.count) * 2 * .pi
        let x = cos(a) * r
        let y = sin(a) * r
        
//        let screen = OverlayHelper.getScreenUnderMouse()
        /// inside the screen we figure out the x and y relative to the radius and angle
        	
        return CGPoint(
            x: r + x, // center X + offset
            y: r + y  // center Y + offset
        )
    }
}

#Preview {
    
    let overlayViewModel = OverlayViewModel(runningAppManager: RunningAppManager())
    
    VStack {
        ComfyTab()
            .environmentObject(overlayViewModel)
    }
    .frame(width: 400, height: 400)
}
