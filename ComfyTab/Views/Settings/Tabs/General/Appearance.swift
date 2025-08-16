//
//  Appearance.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/16/25.
//

import SwiftUI

struct Appearance: View {
    
    @EnvironmentObject private var settingsManager : SettingsManager
    
    var body: some View {
        Picker("App Theme", selection: $settingsManager.colorScheme) {
            ForEach(ColorSchemeSetting.allCases, id: \.self) { schema in
                Text(schema.rawValue)
                    .tag(schema)
            }
        }
    }
}
