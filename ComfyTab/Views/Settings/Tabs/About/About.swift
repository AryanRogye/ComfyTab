//
//  About.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/15/25.
//

import SwiftUI

struct AboutView: View {
    
    var body: some View {
        SettingsContainerView {
            
            SettingsSection {
                headerView
            }
            
            SettingsSection {
                appVersion
                    .padding(8)
                
                Divider().groupBoxStyle()
                
                appBuild
                    .padding(8)
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                appImage
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center) {
                    Text("ComfyTab")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Button {
                        if let url = URL(string: "https://github.com/AryanRogye/ComfyTab") {
                            NSWorkspace.shared.open(url)
                        }
                    } label: {
                        Label("View on GitHub", systemImage: "link")
                    }
                    .buttonStyle(.link)
                    .font(.system(size: 13, weight: .medium))
                    .padding(.leading)
                }
                
                Text("The comfiest way to switch apps on your Mac. Lightweight, fluid, and built to make multitasking feel natural instead of stressful.")
                    .minimumScaleFactor(0.5)
                    .lineLimit(3)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - App Version Number
    private var appVersion: some View {
        Text("Version: \(Bundle.main.versionNumber)")
    }
    
    // MARK: - App Build Number
    private var appBuild: some View {
        Text("Build: \(Bundle.main.buildNumber)")
    }
    
    // MARK: - App Image
    private var appImage: some View {
        Image(nsImage: NSApp.applicationIconImage)
            .resizable()
            .frame(width: 64, height: 64)
            .cornerRadius(12)
    }
    
    // MARK: - Privacy Policy
}


// - [x] App version & build number
// - [ ] “Check for updates” button
// - [x] Links:
// - [ ] Website
// - [ ] Support / Feedback
// - [ ] Privacy Policy
