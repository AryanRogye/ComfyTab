//
//  SettingsView.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/27/25.
//

import SwiftUI

enum SettingTab: String, CaseIterable, Hashable {
    case installedApp = "App Configurations"
    case permissions = "Permissions"
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .installedApp:
            AppConfigurationSettings()
        case .permissions:
            PermissionsView()
        }
    }
}

struct SettingsView: View {
    
    @ObservedObject var permissionManager: PermissionManager
    @ObservedObject var installedAppManager: InstalledAppManager
    
    @StateObject var viewModel = SettingsViewModel()

    var body: some View {
        ComfySplitView {
            /// Impliment Your Own
            Sidebar()
        } content: {
            /// Impliment Your Own
            SettingsContent()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environmentObject(viewModel)
        .environmentObject(permissionManager)
        .environmentObject(installedAppManager)
    }
}
