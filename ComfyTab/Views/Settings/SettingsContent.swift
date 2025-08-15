//
//  SettingsContent.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/15/25.
//

import SwiftUI

struct SettingsContent: View {
    
    @EnvironmentObject var viewModel: SettingsViewModel
    
    var body: some View {
        viewModel.selectedTab.view
            .frame(maxWidth: .infinity,maxHeight: .infinity)
    }
}
