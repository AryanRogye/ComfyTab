//
//  ComfyTabMiddleHiddenAppsView.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/18/25.
//

import SwiftUI

struct ComfyTabMiddleHiddenAppsView: View {
    
    @EnvironmentObject var viewModel: OverlayViewModel
    
    let ns: Namespace.ID
    let onClose: () -> Void
    let onBack: () -> Void
    
    var body: some View {
        ZStack {
            VisualEffectView()
            
            VStack {
                topRow
                    .padding(8)
                
                Divider()
                
                ScrollView(.vertical, showsIndicators: false) {
                    hiddenAppToggle
                        .padding(8)
                }
            }
        }
        .frame(
            width: (viewModel.comfyTabSize.radius * 2),
            height: (viewModel.comfyTabSize.radius * 2) * 0.75
        )
    }
    
    private var topRow: some View {
        HStack {
            Text("Hidden Apps")
            Spacer()
            
            pinButton
            goBack
        }
    }
    
    private var goBack: some View {
        Button(action: onBack) {
            Image(systemName: "arrow.left")
        }
        .buttonStyle(.plain)
    }
    
    
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

    private var hiddenAppToggle: some View {
        ForEach(viewModel.allRunningApps) { app in
            HStack(alignment: .center) {
                if let icon = app.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 16, height: 16)
                }
                Text(app.name)
                
                Spacer()
                
                Toggle("", isOn: binding(for: app))
                    .toggleStyle(.switch)
            }
        }
    }
    
    private func binding(for app: RunningApp) -> Binding<Bool> {
        Binding(
            get: { viewModel.hiddenApps.contains(app) },
            set: { isOn in viewModel.addHiddenApp(isOn, for: app) }
        )
    }
}
