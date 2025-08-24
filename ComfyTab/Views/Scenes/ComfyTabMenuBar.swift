//
//  ComfyTabMenuBar.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/15/25.
//

import SwiftUI

struct ComfyTabMenuBar: Scene {
    
    var settingsCoordinator: SettingsCoordinator
    
    var body: some Scene {
        // TODO: Design Logo
        MenuBarExtra("MyApp", systemImage: "star") {
            VStack {
                Button("Open Settings") {
                    settingsCoordinator.showSettings()
                }
                Divider()
                Button("Quit") {
                    NSApp.terminate(nil)
                }
            }
        }
    }
}
