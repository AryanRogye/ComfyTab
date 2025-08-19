//
//  ComfyTabMiddleSmallView.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/18/25.
//

import SwiftUI

struct ComfyTabMiddleSmallView: View {
    
    @EnvironmentObject var viewModel: OverlayViewModel
    @State private var isHovering: Bool = false
    let ns: Namespace.ID
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .clipShape (
                    Circle()
                )
                .contentShape(Circle())
                .frame(
                    width: viewModel.comfyTabSize.radius / 2 + (isHovering ? 5 : 0),
                    height: viewModel.comfyTabSize.radius / 2 + (isHovering ? 5 : 0)
                )
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .onHover { hovering in
            withAnimation(AppAnims.circleAnimation) {
                isHovering = hovering
            }
        }
    }
}
