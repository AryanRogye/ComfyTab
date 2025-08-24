//
//  ShowDockIcon.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/16/25.
//

import SwiftUI

struct ShowDockIcon: View {
    
    @EnvironmentObject private var viewModel: GeneralViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Show Dock Icon")
                
                Spacer()
                
                Toggle("Show Dock Icon", isOn: viewModel.showDockIcon)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }
            
            Text("The Dock icon is always shown while Settings is open.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
