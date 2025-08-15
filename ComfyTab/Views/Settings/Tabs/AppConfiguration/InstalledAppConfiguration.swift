//
//  InstalledAppConfiguration.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/28/25.
//

import SwiftUI

struct InstalledAppConfiguration: View {
    @EnvironmentObject var installedAppManager: InstalledAppManager
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(installedAppManager.installedApps, id: \.self) { app in
                    showAppDetails(app)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    
    private func showAppDetails(_ app: InstalledApp) -> some View {
        VStack {
            HStack {
                /// App Icon
                if let image = app.image {
                    Image(nsImage: image)
                        .resizable()
                        .frame(width: 20, height: 20)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray)
                        .frame(width: 20, height: 20)
                }
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
