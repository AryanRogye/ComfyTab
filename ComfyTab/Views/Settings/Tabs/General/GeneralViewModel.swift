//
//  GeneralViewModel.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/21/25.
//

import Combine
import SwiftUI

@MainActor
class GeneralViewModel: ObservableObject {
    
    var settingsService: SettingsService
    
    /// ColorScheme Binding
    var colorScheme: Binding<ColorSchemeSetting> {
        Binding(
            get: { self.settingsService.colorScheme },
            set: { self.settingsService.colorScheme = $0 }
        )
    }
    
    /// Show Dock Icon Binding
    var showDockIcon: Binding<Bool> {
        Binding(
            get: { self.settingsService.showDockIcon },
            set: { self.settingsService.showDockIcon = $0 }
        )
    }
    
    /// Launch at Login Binding
    var launchAtLogin: Binding<Bool> {
        Binding(
            get: { self.settingsService.launchAtLogin },
            set: { self.settingsService.launchAtLogin = $0 }
        )
    }
    
    init(deps: GeneralDeps) {
        settingsService = deps.settingsService
    }
}
