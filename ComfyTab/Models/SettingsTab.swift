//
//  SettingsTab.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/19/25.
//

import SwiftUI

enum SettingTab: String, CaseIterable, Hashable {
    case general        = "General"
    case behavior       = "Behavior"
    case permissions    = "Permissions"
    case about          = "About"
    
    var color: Color {
        switch self {
        case .general, .behavior, .permissions, .about:
            return Color.primary.opacity(0.15) // neutral backdrop
        }
    }
    var titleColor: Color {
        switch self {
        case .general, .behavior, .permissions, .about:
            return Color.primary.opacity(0.75) // neutral backdrop
        }
    }
    
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .general:      GeneralSettings()
        case .behavior:     BehaviorSettings()
        case .permissions:  PermissionsView()
        case .about:        AboutView()
        }
    }
    
    /// Gives SystemName
    var icon: String {
        switch self {
        case .general:      return "gearshape"
        case .behavior:     return "slider.horizontal.3"
        case .permissions:  return "lock.shield"
        case .about:        return "info.circle"
        }
    }
}
