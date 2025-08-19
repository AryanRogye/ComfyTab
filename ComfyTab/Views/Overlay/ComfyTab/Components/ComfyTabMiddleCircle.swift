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
        case hiddenApps
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
                } onEye: {
                    withAnimation(AppAnims.circleAnimation) {
                        animateLeft()
                        size = .hiddenApps
                    }
                }
            case .hiddenApps:
                ComfyTabMiddleHiddenAppsView(ns: ns) {
                    withAnimation(AppAnims.circleAnimation) {
                        centerPosition()
                        size = .small
                    }
                } onBack: {
                    withAnimation(AppAnims.circleAnimation) {
                        animateRight()
                        size = .large
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
        .onChange(of: size) { _, value in
            if value == .small {
                viewModel.isPinned = false
            }
        }
    }
    
    private func centerPosition()  {
        position = CGPoint(x: viewModel.comfyTabSize.radius,
                y: viewModel.comfyTabSize.radius)
    }
    
    private func animateLeft() {
        centerPosition()
        position = CGPoint(
            x: position.x - (viewModel.comfyTabSize.radius * 2) - 10,
            y: position.y
        )
    }
    
    private func animateRight() {
        centerPosition()
        position = CGPoint(
            x: position.x + (viewModel.comfyTabSize.radius * 2) + 10,
            y: position.y
        )
    }
}

#Preview {
    var settingsManager = SettingsManager()
    var runningAppManager = RunningAppManager()
    
    var overlay = Overlay(
        runningAppManager: runningAppManager, settingsManager: settingsManager
    )
    let overlayViewModel = OverlayViewModel(runningAppManager: runningAppManager, settingsManager: settingsManager, overlay: overlay)
    
    
    ZStack {
        ComfyTab()
        .environmentObject(overlayViewModel)
        .task {
            overlayViewModel.isShowing = true
            overlayViewModel.getRunningApps()
        }
    }
    .frame(width: 780, height: 300)
    .scaleEffect(0.8)

}
