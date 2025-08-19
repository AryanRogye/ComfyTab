//
//  FilterInstalledApps.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/19/25.
//

import SwiftUI

struct FilterInstalledApps: View {
    var body: some View {
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
}
