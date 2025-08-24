//
//  LaunchAtLogin.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/16/25.
//

import SwiftUI

struct LaunchAtLogin: View {
    
    @EnvironmentObject private var viewModel : GeneralViewModel
    
    var body: some View {
        HStack {
            Text("Launch At Login")
            Spacer()
            Toggle("Launch At Login", isOn: viewModel.launchAtLogin)
                .toggleStyle(.switch)
                .labelsHidden()
        }
    }
}
