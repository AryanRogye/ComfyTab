//
//  ComfyTabApp.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 7/27/25.
//

import SwiftUI

@main
struct ComfyTabApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openWindow) var openWindow
    
    init() {
    }
    
    var body: some Scene {
        MenuBarExtra("MyApp", systemImage: "star") {
            Button("Open Settings") {
                if appDelegate.settingsWindow == nil {
                    appDelegate.settingsWindow = AppWindow(
                        permissionManager: appDelegate.appCoordinator.permissionManager,
                        installedAppManager: appDelegate.appCoordinator.installedAppManager
                    )
                }
                appDelegate.settingsWindow?.makeKeyAndOrderFront(nil)
                appDelegate.settingsWindow?.center()
                NSApp.activate(ignoringOtherApps: true)
            }
            Divider()
            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
    }
}
