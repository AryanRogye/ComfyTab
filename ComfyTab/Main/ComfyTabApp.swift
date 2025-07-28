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
                openWindow(id: "SettingsView")
            }
            Divider()
            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
        
        Window("SettingsView", id: "SettingsView") {
            SettingsView()
        }
    }
}
