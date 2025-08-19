//
//  ComfyTabMiddleLargeView.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/18/25.
//

import SwiftUI

struct ComfyTabMiddleLargeView: View {
    
    @EnvironmentObject var viewModel: OverlayViewModel
    
    let ns: Namespace.ID
    let onTap: () -> Void
    let onEye: () -> Void
    
    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)

            VStack {
                topRow
                    .padding(8)
                
                Divider()
                
                rescanApps
                    .padding(4)
                
                Divider()
                
                revealAppInFinder
                    .padding(8)
                
                Divider()
                
                Spacer()
            }
        }
        .frame(
            width: viewModel.comfyTabSize.radius * 2,
            height: viewModel.comfyTabSize.radius * 2
        )
    }
    
    // MARK: - Top Row
    private var topRow: some View {
        HStack {
            Text("Quick Configurations")
            Spacer()
            
            eyeButton
            pinButton
            closeButton
        }
    }
    
    // MARK: - Reveal App In Finder
    private var revealAppInFinder: some View {
        VStack(alignment: .leading ,spacing: 8) {
            
            Text("Reveal App In Finder")
                
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(viewModel.runningApps) { app in
                        Button(action: {
                            viewModel.onFinderOpen(app)
                        }) {
                            if let icon = app.icon {
                                Image(nsImage: icon)
                                    .resizable()
                                    .frame(width: 22, height: 22)
                            } else {
                                RoundedRectangle(cornerRadius: 6)
                                    .frame(width: 22, height: 22)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(height: 30)
        }
    }
    
    // MARK: - RE-Scan Apps
    private var rescanApps: some View {
        HStack {
            
            Button(action: {
                viewModel.getRunningApps()
            }) {
                Text("Re Scan App")
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.1))
                    }
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
    }
    
    // MARK: - Eye Button
    private var eyeButton: some View {
        Button(action: onEye) {
            Image(systemName: "eye.slash.fill")
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Close Button
    private var closeButton: some View {
        Button(action: onTap) {
            Image(systemName: "xmark")
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
        }
        .buttonStyle(.plain)
    }
}
