//
//  SettingsView.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/27/25.
//

import SwiftUI

enum SettingTab: String, CaseIterable {
    case permissions = "Permissions"
    
    var view: some View {
        switch self {
        case .permissions: PermissionsView()
        }
    }
}

public struct SettingsView: View {
    
    @State private var selectedTab: SettingTab = .permissions
    
    public var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                ForEach(SettingTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue)
                }
            }
        } detail: {
            selectedTab.view
        }
    }
}
