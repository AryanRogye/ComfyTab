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
}

public struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @State private var selection: SettingTab = .installedApp
    
    public var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(SettingTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue)
                }
            }
            .onChange(of: selection) { _, newValue in
                viewModel.selectedTab = newValue
            }
        } detail: {
            NavigationStack {
                switch viewModel.selectedTab {
                case .installedApp: AppConfigurationSettings()
                case .permissions: PermissionsView()
                }
            }
        }
    }
}

