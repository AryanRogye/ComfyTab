//
//  IntroAnimation.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/17/25.
//

import SwiftUI

struct IntroAnimation: View {
    
    @EnvironmentObject private var settingsManager: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Intro Animation")
                Spacer()
                Toggle("Intro Animation", isOn: $settingsManager.isIntroAnimationEnabled)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }
            Text("Play a quick ring fill the first time ComfyTab opens.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
