//
//  General.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/15/25.
//

import SwiftUI

struct GeneralSettings: View {
    var body: some View {
        SettingsContainerView {
            /// General View is pretty small, later on we can break it up
            SettingsSection {
                
                Appearance()
                    .padding(8)
                
                Divider()
                
                ShowDockIcon()
                    .padding(8)
                
                Divider()
                
                LaunchAtLogin()
                    .padding(8)
                
            }
            .padding(.top)
        }
    }
}
