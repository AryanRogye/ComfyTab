//
//  OverlayHome.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import SwiftUI

struct OverlayHome: View {
    
    @EnvironmentObject var viewModel : OverlayViewModel
    
    var body: some View {
        VStack(spacing: 1) {
            ScrollView {
                ForEach(viewModel.runningApps) { app in
                    HStack {
                        if let icon = app.icon {
                            Image(nsImage: icon)
                        }
                        Text(app.name)
                    }
                }
            }
        }
        .onChange(of: viewModel.isShowing) { _, value in
            if value {
                viewModel.getRunningApps()
            }
        }
    }
}
