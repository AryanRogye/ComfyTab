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
            appearanceSettings
            triggerSettings
            startUpSettings
        }
    }
    
    private var appearanceSettings: some View {
        SettingsSection {
            
        }
    }
    
    private var triggerSettings: some View {
        SettingsSection("Trigger") {
            TriggerSettings()
                .padding()
        }
    }
    
    private var startUpSettings: some View {
        SettingsSection {
        }
    }
}
