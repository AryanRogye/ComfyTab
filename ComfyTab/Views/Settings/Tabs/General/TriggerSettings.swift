//
//  TriggerSettings.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/15/25.
//

import SwiftUI

struct TriggerSettings: View {
    
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        VStack {
            Picker("Pick a Modifier Key", selection: $settingsManager.modifierKey) {
                ForEach(ModifierKey.allCases) { key in
                    Text(key.label)
                        .tag(key)
                }
            }
        }
    }
}
