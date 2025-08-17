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
                
                Divider().groupBoxStyle()
                
                linkRow
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
                    
                    Link(destination: URL(string: "https://github.com/AryanRogye/ComfyTab")!) {
                        Label("View on GitHub", systemImage: "link")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .help("Open the ComfyTab repository on GitHub")
                    .accessibilityLabel("View on GitHub")
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
    
    // MARK: - Links Section
    private var linkRow: some View {
        HStack(spacing: 12) {
            Link(destination: URL(string: "https://github.com/AryanRogye/ComfyTab/blob/main/PRIVACY.md")!) {
                Label("Privacy Policy", systemImage: "lock.shield")
            }
            .accessibilityLabel("Privacy Policy")
            
            Link(destination: URL(string: "https://github.com/AryanRogye/ComfyTab/issues")!) {
                Label("Support / Feedback", systemImage: "questionmark.circle")
            }
            .accessibilityLabel("Support and Feedback")
            
            // Swap this to your future landing page when ready.
            Link(destination: URL(string: "https://github.com/AryanRogye/ComfyTab")!) {
                Label("Website", systemImage: "globe")
            }
            .accessibilityLabel("Website")
        }
        .font(.system(size: 13, weight: .medium))
        .buttonStyle(.link)
    }
}
