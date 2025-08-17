//
//  HoverEffect.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/17/25.
//

import SwiftUI

struct HoverEffect: View {
    
    @EnvironmentObject private var settingsManager : SettingsManager
    
    var body: some View {
        HStack {
            Text("Hover Effect")
            
            Spacer()
            
            Toggle("Hover Effect", isOn: $settingsManager.isHoverEffectEnabled)
                .toggleStyle(.switch)
                .labelsHidden()
        }
    }
}
