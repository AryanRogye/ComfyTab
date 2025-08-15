//
//  ComfyTabMenuBar.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/15/25.
//

import SwiftUI

struct ComfyTabMenuBar: Scene {
    
    @EnvironmentObject private var settingsManager: SettingsManager
    @Environment(\.openWindow) private var openWindow
    
    var body: some Scene {
        MenuBarExtra("MyApp", systemImage: "star") {
            Button("Open Settings") {
                openWindow(id: "SettingsView")
                NSApp.activate(ignoringOtherApps: true)
                settingsManager.isSettingsWindowOpen = true
            }
            Divider()
            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
    }
}
