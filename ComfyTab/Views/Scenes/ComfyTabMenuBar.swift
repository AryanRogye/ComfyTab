//
//  ComfyTabMenuBar.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/15/25.
//

import SwiftUI

struct ComfyTabMenuBar: Scene {
    
    var appEnv: AppEnv
    var settingsCoordinator: SettingsCoordinator
    
    var body: some Scene {
        MenuBarExtra("MyApp", systemImage: "star") {
            VStack {
                Button("Open Settings") {
                    NSApp.activate(ignoringOtherApps: true)
                    settingsCoordinator.showSettings()
                    appEnv.settingsManager.isSettingsWindowOpen = true
                }
                Divider()
                Button("Quit") {
                    NSApp.terminate(nil)
                }
            }
        }
    }
}
