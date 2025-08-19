//
//  AppConfigurationSettings.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import SwiftUI

public struct AppConfigurationSettings: View {
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                installedAppsSettings
                    .padding([.horizontal])
                    .padding(.vertical, 8)
                
                Divider()
                
                blockedAppSettings
                    .padding([.horizontal])
                    .padding(.vertical, 8)
            }
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background.secondary)
            }
            .padding()
        }
    }
    
    // MARK: - Installed App Settings
    private var installedAppsSettings: some View {
        NavigationLink(destination: InstalledAppConfiguration()) {
            HStack {
                Label("Installed Apps", systemImage: "folder.fill")
                    .font(.system(size: 14, weight: .regular, design: .default))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .foregroundColor(.secondary)
                    .frame(width: 11, height: 12)
            }
            .frame(maxWidth: .infinity, minHeight: 30)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private var blockedAppSettings: some View {
        Button(action: {}) {
            HStack {
                Label("Blocked Apps", systemImage: "xmark.circle.fill")
                    .font(.system(size: 14, weight: .regular, design: .default))

                Spacer()
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .foregroundColor(.secondary)
                    .frame(width: 11, height: 12)
            }
            .frame(maxWidth: .infinity, minHeight: 30)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
