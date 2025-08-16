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
        }
    }
}
