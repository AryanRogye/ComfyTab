//
//  ComfyTab.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/15/25.
//

import SwiftUI
import Combine
import CoreGraphics

/// Donut Shaped
struct ComfyTab: View {
    
    @EnvironmentObject var viewModel: OverlayViewModel
    @StateObject private var internalViewModel = ViewModel()
    
    var body: some View {
        ZStack {
#if DEBUG
            if showDebug {
                Text("Middle")
            }
#endif
            
            ComfyTabMiddleCircle()
            
            /// If Not Empty
            if !viewModel.visibleApps.isEmpty {
                appsView
            }
        }
        .onChange(of: viewModel.isShowing) { _, isShowing in
            if isShowing {
                viewModel.getRunningApps()
            } else {
                viewModel.resetVisibleApps()
            }
        }
        .onChange(of: viewModel.runningApps) { _, apps in
            guard viewModel.isShowing else { return }
            
            /// Only add Apps One By One if the into is enabled
            if viewModel.isIntroAnimationEnabled {
                viewModel.addAppsOneByOne(apps: viewModel.runningApps)
            } else {
                viewModel.setVisibleAppsInstant(viewModel.runningApps)
            }
        }
    }
    
    // MARK: - App View
    private var appsView: some View {
        let s = ComfyTabLayout.makeSlices(viewModel.visibleApps)
        return ZStack {
            ForEach(s, id: \.app.bundleID) { s in
                
                circlePiece(index: s.index,
                            start: s.start,
                            end: s.end,
                            app: s.app
                )
                .contentShape(
                    CirclePiece(
                        startAngle: s.start,
                        endAngle: s.end,
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
    
    // MARK: - Circle Piece
    /// circle piece allows us to get the hover on each one we set it for
    private func circlePiece(
        index: Int,
        start: Angle,
        end: Angle,
        app: RunningApp
    ) -> some View {
        Button(action: {
            viewModel.focusApp(index: index)
        }) {
            ZStack {
                let isHovered = internalViewModel.hoveringIndex == index
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
                        /// TODO: Maybe oneday we can add shaders😓 this just doesnt look any different
                        /// TODO: Check out Metal Folder
                    }
                }
                .transition(.identity)
                
                VStack {
                    icon(for: app, index: index)
                    /// Swtich for the app icon names
                    if viewModel.showAppNameUnderIcon {
                        Text(app.name)
                            .font(.system(
                                size: 8,
                                weight: .regular,
                                design: .default
                            ))
                    }
                }
                .position(internalViewModel.labelPosition(
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
            withAnimation(AppAnims.circleAnimation) {
                internalViewModel.hoveringIndex = hovering && viewModel.isHoverEffectEnabled
                ? index : nil
            }
        }
    }
    
    // MARK: - App Icon
    /// Singular App View
    private func icon(for app: RunningApp, index: Int) -> some View {
        Group {
            Image(nsImage: viewModel.getAppIcon(for: app))
                .resizable()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
        }
        /// Lil Performance
        .shadow(radius:
                    viewModel.visibleApps.count < 10
                ? 4 : 0
        )
        .contentShape(Circle())
    }
}
