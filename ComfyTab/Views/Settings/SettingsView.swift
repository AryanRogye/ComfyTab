//
//  SettingsView.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/27/25.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var viewModel : SettingsViewModel
    
    var body: some View {
        NavigationSplitView {
            Sidebar()
        } detail: {
            SettingsContent()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environmentObject(viewModel)
        .onAppear {
            onAppear()
        }
    }
    
    private func onAppear() {
        /// Mark as True
        viewModel.settingsService.isSettingsWindowOpen = true
        
        /// Make Sure That the Window is Above runs after 0.2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NSApp.activate(ignoringOtherApps: true)
            
            // Find window by title or identifier
            if let window = NSApp.windows.first(where: {
                $0.title.contains("Settings") || $0.identifier?.rawValue == "SettingsView"
            }) {
                window.makeKeyAndOrderFront(nil)
                window.orderFrontRegardless()
            }
        }
    }
}

struct Sidebar: View {
    
    @EnvironmentObject var viewModel: SettingsViewModel
    @State private var selectedTab : SettingTab = .general
    
    var body: some View {
        List(selection: $selectedTab) {
            Section {
                ForEach(SettingTab.allCases, id: \.self) { tab in
                    Label {
                        Text(tab.rawValue)
                            .padding(.leading, 8)
                    } icon: {
                        Image(systemName: tab.icon)
                            .iconWithRectangle(
                                bg: tab.color
                            )
                    }
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
        VStack(spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: viewModel.selectedTab.icon)
                    .iconWithRectangle(
                        size: 25,
                        bg: viewModel.selectedTab.titleColor
                    )
                
                Text(viewModel.selectedTab.rawValue)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal)
            
            Divider()
            
            viewModel.selectedTab.view
                .frame(maxWidth: .infinity,maxHeight: .infinity)
        }
    }
}
