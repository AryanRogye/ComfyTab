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
    
    var body: some View {
        ZStack {
            VisualEffectView()
            
            VStack {
                topRow
                    .padding(8)
                
                Divider()
                
                ScrollView {
                    DisclosureGroup("Hidden Apps") {
                        hiddenApps
                    }
                }
                .padding(8)
                
                
                Spacer()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
        )
        .frame(
            width: viewModel.comfyTabSize.radius * 2,
            height: viewModel.comfyTabSize.radius * 2
        )
    }
    
    private var topRow: some View {
        HStack {
            Text("ComfyTab Quick Configurations")
            Spacer()
            
            pinButton
            closeButton
        }
    }
    
    private var closeButton: some View {
        Button(action: onTap) {
            Image(systemName: "xmark")
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
    
    private var hiddenApps: some View {
        ForEach(viewModel.allRunningApps) { app in
            HStack {
                if let icon = app.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 20, height: 20)
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
