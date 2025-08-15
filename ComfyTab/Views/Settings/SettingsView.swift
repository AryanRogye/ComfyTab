//
//  SettingsView.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/27/25.
//

import SwiftUI

enum SettingTab: String, CaseIterable, Hashable {
    case general        = "General"
    // TODO: Add App Configuration Settings inside Behavior
    case behavior       = "Behavior"
    case permissions    = "Permissions"
    case about          = "About"
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .general:      GeneralSettings()
            // TODO: Add App Configuration Settings inside Behavior
            //            AppConfigurationSettings()
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

struct SettingsView: View {
    
    @EnvironmentObject var installedAppManager: InstalledAppManager
    @EnvironmentObject var permissionManager: PermissionManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @StateObject var viewModel = SettingsViewModel()

    var body: some View {
        NavigationSplitView {
            Sidebar()
        } detail: {
            SettingsContent()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environmentObject(viewModel)
    }
}

struct Sidebar: View {
    
    @EnvironmentObject var viewModel: SettingsViewModel
    @State private var selectedTab : SettingTab = .general
    
    var body: some View {
        List(selection: $selectedTab) {
            Section {
                ForEach(SettingTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue)
                }
            } header: {
                Text("ComfyTab")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(.primary)
                    .padding(.vertical, 5)
            }
            .collapsible(false)
        }
        .scrollDisabled(true)
        .navigationSplitViewColumnWidth(200)
        /// Helps With Not Publishing View Updates
        .onAppear {
            selectedTab = viewModel.selectedTab
        }
        .onChange(of: selectedTab) { _, newValue in
            viewModel.selectedTab = newValue
        }
    }
}

struct SettingsContent: View {
    
    @EnvironmentObject var viewModel: SettingsViewModel
    
    var body: some View {
        viewModel.selectedTab.view
            .frame(maxWidth: .infinity,maxHeight: .infinity)
    }
}
