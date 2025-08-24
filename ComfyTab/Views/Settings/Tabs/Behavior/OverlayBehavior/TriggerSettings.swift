//
//  TriggerSettings.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/15/25.
//

import SwiftUI

struct ModifierKeyPicker: View {
    
    @EnvironmentObject var viewModel: BehaviorViewModel
    
    var body: some View {
        VStack {
            Picker("Pick a Modifier Key", selection: viewModel.modifierKey) {
                ForEach(ModifierKey.allCases) { key in
                    Text(key.label)
                        .tag(key)
                }
            }
        }
    }
}
