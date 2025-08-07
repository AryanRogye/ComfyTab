//
//  OverlayContent.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import SwiftUI

struct OverlayContent: View {
    
    @EnvironmentObject var viewModel : OverlayViewModel
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                overlay
                    .scaleEffect(viewModel.isShowing ? 1.0 : 0.95)
                    .opacity(viewModel.isShowing ? 1.0 : 0.0)
                    .offset(y: viewModel.isShowing ? 0 : 10)
                    .blur(radius: viewModel.isShowing ? 0 : 1.5)
                    .shadow(radius: viewModel.isShowing ? 2 : 1)
                    .animation(
                        .interpolatingSpring(
                            stiffness: 120,
                            damping: 22
                        ),
                        value: viewModel.isShowing
                    )
                Spacer()
            }
            Spacer()
        }
    }
    
    private var overlay: some View {
        ZStack(alignment: .top) {
            
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
            
            VStack(spacing: 0) {
                
                topRow
                    .padding([.horizontal, .top], 8)
                    .frame(alignment: .top)
                
                
//                switch viewModel.overlayState {
//                case .homeView: OverlayHome().frame(width: 200, height: 200)
//                case .configureVibe: OverlayConfigureVibe().frame(width: 200, height: 200)
//                case .goWithFlow: OverlayGoWithFlow().frame(width: 200, height: 200)
//                }
            }
        }
        .frame(width: viewModel.overlay.width, height: viewModel.overlay.height)
    }
    
    // MARK: - Top Row
    private var topRow: some View {
        HStack(alignment: .top) {
            if viewModel.lastState != nil {
                backButton
            }
            Spacer()
            pinButton
        }
    }
    
    // MARK: - Back Button
    private var backButton: some View {
        Button(action: viewModel.goBack) {
            Image(systemName: "arrowshape.backward")
                .resizable()
                .foregroundColor(.secondary)
                .frame(width: 14, height: 14)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Pin Button
    private var pinButton: some View {
        Button(action : {
            viewModel.togglePinned()
        }) {
            Image(systemName: viewModel.isPinned
                  ? "pin.fill"
                  : "pin"
            )
            .resizable()
            .foregroundColor(.secondary)
            .frame(width: 14, height: 17)
        }
        .buttonStyle(.plain)
    }
}
