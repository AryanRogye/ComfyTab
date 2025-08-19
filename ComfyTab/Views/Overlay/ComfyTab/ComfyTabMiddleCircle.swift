//
//  ComfyTabMiddleCircle.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/18/25.
//

import SwiftUI

struct ComfyTabMiddleCircle: View {
    
    enum Size {
        case small
        case large
    }
    
    @EnvironmentObject var viewModel: OverlayViewModel
    @State private var size: Size = .small
    @Namespace private var ns
    
    @State private var position: CGPoint = .zero

    var body: some View {
        ZStack {
            switch size {
            case .small:
                ComfyTabMiddleSmallView(ns: ns) {
                    withAnimation(AppAnims.circleAnimation) {
                        animateRight()
                        size = .large
                    }
                }
            case .large:
                ComfyTabMiddleLargeView(ns: ns) {
                    withAnimation(AppAnims.circleAnimation) {
                        centerPosition()
                        size = .small
                    }
                }
            }
        }
        .position(position)
        .frame(width: viewModel.comfyTabSize.radius * 2,
               height: viewModel.comfyTabSize.radius * 2,
               alignment: .center)
        .onChange(of: viewModel.isShowing) {
            /// Ensures when we show/hide its always small
            size = .small
            centerPosition()
        }
    }
    
    private func centerPosition()  {
        position = CGPoint(x: viewModel.comfyTabSize.radius,
                y: viewModel.comfyTabSize.radius)
    }
    
    private func animateRight() {
        position = CGPoint(
            x: position.x + (viewModel.comfyTabSize.radius * 2) + 10,
            y: position.y
        )
    }
}

#Preview {
    @Previewable @Namespace var ns
    let overlayViewModel = OverlayViewModel(runningAppManager: RunningAppManager(), settingsManager: SettingsManager())

    
    ZStack {
        ComfyTabMiddleSmallView(
            ns: ns
        ) {
            
        }
    }
    .environmentObject(overlayViewModel)
    .task {
        overlayViewModel.isShowing = true
        overlayViewModel.getRunningApps()
    }
    .frame(width: 300, height: 100)

    
    ZStack {
        ComfyTabMiddleLargeView(
            ns: ns
        ) {
            
        }
    }
    .environmentObject(overlayViewModel)
    .task {
        overlayViewModel.isShowing = true
        overlayViewModel.getRunningApps()
    }
    .frame(width: 300, height: 300)
    
    ZStack {
        ComfyTab(
            parameters: LiquidGlassParameters()
        )
        .environmentObject(overlayViewModel)
        .task {
            overlayViewModel.isShowing = true
            overlayViewModel.getRunningApps()
        }
    }
    .frame(width: 780, height: 300)

}
