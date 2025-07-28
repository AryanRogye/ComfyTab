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
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
            
            VStack() {
                topRow
                    .padding(.horizontal, 8)
                    .padding(.top, 12)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
    
    // MARK: - Top Row
    private var topRow: some View {
        HStack(alignment: .top) {
            pinButton
            
            Spacer()
        }
    }
    
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
            .frame(width: 14, height: 14)
        }
        .buttonStyle(.plain)
    }
    
}

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .sidebar
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.wantsLayer = true
        view.layer?.cornerRadius = 12
        view.layer?.masksToBounds = true
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
