//
//  SettingsWindowScene.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/19/25.
//

import SwiftUI

struct SettingsWindowScene: Scene {
    
    var appDelegate: AppDelegate
    
    var body: some Scene {
        if #available(macOS 15.0, *) {
            return Window("SettingsView", id: "SettingsView") {
                SettingsView()
                    .environmentObject(appDelegate.appCoordinator.installedAppManager)
                    .environmentObject(appDelegate.appCoordinator.permissionManager)
                    .environmentObject(appDelegate.appCoordinator.settingsManager)
            }
            .commandsRemoved()
            .windowResizability(.contentSize)
            .windowStyle(.hiddenTitleBar)
            .defaultSize(width: 900, height: 625)
            .defaultLaunchBehavior(.suppressed)
            .defaultPosition(.center)
        } else {
            return Window("SettingsView", id: "SettingsView") {
                SettingsView()
                    .environmentObject(appDelegate.appCoordinator.installedAppManager)
                    .environmentObject(appDelegate.appCoordinator.permissionManager)
                    .environmentObject(appDelegate.appCoordinator.settingsManager)
            }
            .commandsRemoved()
            .windowResizability(.contentSize)
            .windowStyle(.hiddenTitleBar)
            .defaultSize(width: 900, height: 625)
            .defaultPosition(.center)
        }
    }
}
