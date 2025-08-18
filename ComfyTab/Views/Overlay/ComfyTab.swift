//
//  ComfyTab.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/15/25.
//

import SwiftUI
import CoreGraphics

/// Donut Shaped
struct ComfyTab: View {
    
    @EnvironmentObject var viewModel: OverlayViewModel
    
    /// What index we're hovering on
    @State private var hoveringIndex: Int? = nil
    
    private let iconSize: CGFloat           = 48
    private let distanceFromCenter: CGFloat = 130
    private let hoverPopOut: CGFloat        = 12
    private let angleOffset: CGFloat        = -.pi/2
    
    @State private var visibleApps: [RunningApp] = []
    var parameters = LiquidGlassParameters()
    
    var body: some View {
        ZStack {
            #if DEBUG
            if showDebug {
                Text("Middle")
            }
            #endif
            /// If User wants animation on the opening
            if viewModel.settingsManager.isIntroAnimationEnabled {
                appsViewAnimated
            } else {
                appsView
            }
        }
        .onChange(of: viewModel.isShowing) { _, value in
            if value {
                viewModel.getRunningApps()
            } else {
                visibleApps = []
            }
        }
        .onChange(of: viewModel.runningApps) { _, apps in
            guard viewModel.isShowing else { return }
            /// Only add Apps One By One if the into is enabled
            if viewModel.settingsManager.isIntroAnimationEnabled {
                addAppsOneByOne(apps: apps)
            }
        }
    }
    
    // MARK: - App View
    private var appsView: some View {
        ZStack {
            ForEach(Array(viewModel.runningApps.enumerated()), id: \.offset) { index, app in
                let count = viewModel.runningApps.count
                let start = Angle(degrees: Double(index) * 360.0 / Double(count))
                let end   = Angle(degrees: Double(index+1) * 360.0 / Double(count))
                
                circlePiece(index: index,
                            count: count,
                            start: start,
                            end: end,
                            app: app
                )
                .contentShape(
                    CirclePiece(
                        startAngle: start,
                        endAngle: end,
                        radius: viewModel.comfyTabSize.radius,
                        thickness: viewModel.comfyTabSize.thickness
                    )
                )
            }
        }
        .frame(width: viewModel.comfyTabSize.radius * 2,
               height: viewModel.comfyTabSize.radius * 2,
               alignment: .center)
    }
    
    // MARK: - App View Animated
    private var appsViewAnimated: some View {
        ZStack {
            ForEach(Array(visibleApps.enumerated()), id: \.offset) { index, app in
                let count = visibleApps.count
                let start = Angle(degrees: Double(index) * 360.0 / Double(count))
                let end   = Angle(degrees: Double(index+1) * 360.0 / Double(count))
                
                circlePiece(index: index,
                            count: count,
                            start: start,
                            end: end,
                            app: app
                )
                .contentShape(
                    CirclePiece(
                        startAngle: start,
                        endAngle: end,
                        radius: viewModel.comfyTabSize.radius,
                        thickness: viewModel.comfyTabSize.thickness
                    )
                )
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: visibleApps)
            }
        }
        .frame(width: viewModel.comfyTabSize.radius * 2,
               height: viewModel.comfyTabSize.radius * 2,
               alignment: .center)
    }
    
    
    // MARK: - Circle Piece
    private func circlePiece(
        index: Int,
        count: Int,
        start: Angle,
        end: Angle,
        app: RunningApp
    ) -> some View {
        Button(action: {
            viewModel.focusApp(index: index)
        }) {
            ZStack {
                let isHovered = hoveringIndex == index
                let extraRadius: CGFloat = isHovered ? 12 : 0
                
                ZStack {
                    if isHovered {
                        CirclePiece(
                            startAngle: start,
                            endAngle: end,
                            radius: viewModel.comfyTabSize.radius + extraRadius,
                            thickness: viewModel.comfyTabSize.thickness
                        )
                        .fill(Color.white.opacity(0.2))
                    } else {
                        VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                            .mask (
                                CirclePiece(
                                    startAngle: start,
                                    endAngle: end,
                                    radius: viewModel.comfyTabSize.radius + extraRadius,
                                    thickness: viewModel.comfyTabSize.thickness
                                )
                                .fill(Color.white.opacity(0.8))
                            )
                        // TODO: Maybe oneday we can add shaders😓 this just doesnt look any different
//                        LiquidGlassBackground(
//                            params: parameters
//                        )
//                            .mask(
//                                CirclePiece(
//                                    startAngle: start,
//                                    endAngle: end,
//                                    radius: viewModel.comfyTabSize.radius + extraRadius,
//                                    thickness: viewModel.comfyTabSize.thickness
//                                )
//                                .fill(Color.white.opacity(0.8))
//                            )
                    }
                }
                .transition(.identity)
                
                VStack {
                    icon(for: app.icon, index: index)
                    /// Swtich for the app icon names
                    if viewModel.settingsManager.showAppNameUnderIcon {
                        Text(app.name)
                            .font(.system(
                                size: 8,
                                weight: .regular,
                                design: .default
                            ))
                    }
                }
                .position(labelPosition(
                    startAngle: start,
                    endAngle: end,
                    radius: viewModel.comfyTabSize.radius,
                    thickness: viewModel.comfyTabSize.thickness,
                    offset: extraRadius
                ))
                .transition(.identity)
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                hoveringIndex = hovering && viewModel.settingsManager.isHoverEffectEnabled
                ? index : nil
            }
        }
    }
    
    // MARK: - App Icon
    /// Singular App View
    private func icon(for icon: NSImage?, index: Int) -> some View {
        Group {
            if let icon = icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
            } else {
                Circle().fill(.gray)
            }
        }
        .shadow(radius: 4)
        .contentShape(Circle())
    }
    
    // MARK: - Helpers
    
    /// Used for positioning of the lables
    private func labelPosition(
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
    
    /// Function will add apps into the array, one by one, this simulates a nice animation
    private func addAppsOneByOne(apps: [RunningApp]) {
        visibleApps = []
        for (i, app) in apps.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    visibleApps.append(app)
                }
            }
        }
    }
}

#Preview {
    
    let overlayViewModel = OverlayViewModel(runningAppManager: RunningAppManager(), settingsManager: SettingsManager())
    
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
    .frame(width: 300, height: 300)
}
