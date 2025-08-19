//
//  Behavior.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/15/25.
//

import SwiftUI

struct BehaviorSettings: View {
    var body: some View {
        NavigationStack {
            SettingsContainerView {
                overlayBehavior
                    .padding(.top)
                appFiltering
            }
        }
    }
    
    private var appFiltering: some View {
        SettingsSection("App Filtering") {
            FilterInstalledApps()
                .padding(8)
        }
    }
    
    private var overlayBehavior: some View {
        SettingsSection("Overlay Behavior") {
            ModifierKeyPicker()
                .padding(8)
            
            Divider().groupBoxStyle()
            
            IntroAnimation()
                .padding(8)
            
            Divider().groupBoxStyle()
            
            ShowAppNameUnderIcon()
                .padding(8)
            
            Divider().groupBoxStyle()

            HoverEffect()
                .padding(8)
        }
    }
}
