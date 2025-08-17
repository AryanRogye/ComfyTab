//
//  Behavior.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/15/25.
//

import SwiftUI

struct BehaviorSettings: View {
    var body: some View {
        SettingsContainerView {
            overlayBehavior
                .padding(.top)
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
