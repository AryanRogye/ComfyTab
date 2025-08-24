//
//  InstalledAppConfiguration.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct InstalledAppConfiguration: View {
    
    @EnvironmentObject var viewModel: BehaviorViewModel
    
    var body: some View {
        SettingsContainerView {
            SettingsSection {
                if viewModel.doneLoading {
                    ForEach(viewModel.installedAppService.installedApps, id: \.self) { app in
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
            viewModel.installedAppService.fetchApps()
            viewModel.updateIcons(viewModel.installedAppService.installedApps)
        }
        .onDisappear {
            viewModel.removeIconsFromCache(
                viewModel.installedAppService.installedApps
            )
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
