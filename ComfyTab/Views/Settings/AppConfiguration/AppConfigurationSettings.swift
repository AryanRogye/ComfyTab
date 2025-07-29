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
            VStack {
                installedAppsSettings
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                Divider()
                    .padding(.vertical, 4)
                
                blockedAppSettings
                    .padding(.horizontal)
                    .padding(.bottom, 8)
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
                Text("Installed Apps")
                    .font(.system(size: 12, weight: .medium, design: .default))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .foregroundColor(.secondary)
                    .frame(width: 12, height: 12)
            }
        }
        .buttonStyle(.plain)
    }
    
    private var blockedAppSettings: some View {
        Button(action: {}) {
            HStack {
                Text("Blocked Apps")
                    .font(.system(size: 12, weight: .medium, design: .default))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .foregroundColor(.secondary)
                    .frame(width: 12, height: 12)
            }
        }
        .buttonStyle(.plain)
    }
}
