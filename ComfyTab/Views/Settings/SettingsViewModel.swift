//
//  SettingsViewModel.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    
    @Published var selectedTab: SettingTab = .general
    
}
