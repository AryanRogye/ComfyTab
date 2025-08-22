//
//  SettingsWindowScene.swift
//  ComfyTab
//
//  Created by Aryan Rogye on 8/19/25.
//

import SwiftUI

//struct SettingsWindowScene: Scene {
//    
//    var appDelegate: AppDelegate
//    
//    var body: some Scene {
//        if #available(macOS 15.0, *) {
//            return Window("SettingsView", id: "SettingsView") {
//                SettingsView()
//                    .environmentObject(appDelegate.appEnv.installedAppManager)
//                    .environmentObject(appDelegate.appEnv.permissionManager)
//                    .environmentObject(appDelegate.appEnv.settingsManager)
//                
//            }
//            .commandsRemoved()
//            .windowResizability(.contentSize)
//            .windowStyle(.hiddenTitleBar)
//            .defaultSize(width: 900, height: 625)
//            .defaultLaunchBehavior(.suppressed)
//            .defaultPosition(.center)
//            } else {
//                return Window("SettingsView", id: "SettingsView") {
//                    SettingsView()
//                        .environmentObject(appDelegate.appEnv.installedAppManager)
//                        .environmentObject(appDelegate.appEnv.permissionManager)
//                        .environmentObject(appDelegate.appEnv.settingsManager)
//                    
//                }
//                .commandsRemoved()
//                .windowResizability(.contentSize)
//                .windowStyle(.hiddenTitleBar)
//                .defaultSize(width: 900, height: 625)
//                .defaultPosition(.center)
//            }
//    }
//}
