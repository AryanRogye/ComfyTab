//
//  InstalledAppConfiguration.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import SwiftUI
import UniformTypeIdentifiers

extension InstalledAppConfiguration {
    @Observable @MainActor
    class ViewModel {
        
        var doneLoading = false
        
        public func getIcon(for app: InstalledApp) -> NSImage {
            let image : NSImage? = AppIconManager.appIcons[app.bundleID ?? ""]
            return image ?? AppIconManager.fallbackAppIcon()
        }
        
        public func updateIcons(_ apps: [InstalledApp]) {
            apps.forEach { app in
                    
                let url = app.url
                let bundle = app.bundleID ?? ""
                
                AppIconManager.loadAppIcon(for: url,bundleID: bundle) { _ in }
            }
            doneLoading = true
        }
        
        public func removeIconsFromCache(_ apps: [InstalledApp]) {
            apps.forEach {
                AppIconManager.removeAppIcon(for: $0.bundleID ?? "")
            }
        }
    }
}
struct InstalledAppConfiguration: View {
    
    @EnvironmentObject var installedAppManager: InstalledAppManager
    @State var viewModel = ViewModel()
    
    var body: some View {
        SettingsContainerView {
            SettingsSection {
                if viewModel.doneLoading {
                    ForEach(installedAppManager.installedApps, id: \.self) { app in
                        showAppDetails(app)
                    }
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(.top, 8)
        }
        .onAppear {
            installedAppManager.fetchApps()
            viewModel.updateIcons(installedAppManager.installedApps)
        }
        .onDisappear {
            viewModel.removeIconsFromCache(installedAppManager.installedApps)
        }
    }
    
    
    private func showAppDetails(_ app: InstalledApp) -> some View {
        VStack {
            HStack {
                /// App Icon
                Image(nsImage: viewModel.getIcon(for: app))
                    .resizable()
                    .frame(width: 20, height: 20)
                /// App Name
                Text(app.name)
                    .font(.system(
                        size: 11,
                        weight: .medium,
                        design: .default
                    ))
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            Divider()
                .padding(.vertical, 4)
        }
    }
}
